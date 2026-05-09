import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io'
    show
        Platform;

// Singleton service for scheduling and managing local push notifications
class NotificationService {
  static final NotificationService
  _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin
  _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize timezone data and request platform-specific notification permissions
  Future<
    void
  >
  init() async {
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).toString();
      print(
        'Raw timezone name from device: $timeZoneName',
      );

      // Try to get the location with the raw name first
      try {
        tz.setLocalLocation(
          tz.getLocation(
            timeZoneName,
          ),
        );
        print(
          'Timezone set to: $timeZoneName',
        );
      } catch (
        e
      ) {
        // If that fails, try to find a matching timezone from available zones
        print(
          'Exact timezone match failed, attempting to find alternative...',
        );
        final availableTimeZones = tz.timeZoneDatabase.locations.keys.toList();
        bool found = false;

        // Try to find a timezone containing part of the name
        for (String tz_name in availableTimeZones) {
          if (timeZoneName.contains(
                '/',
              ) &&
              tz_name.contains(
                timeZoneName
                    .split(
                      '/',
                    )
                    .last,
              )) {
            try {
              tz.setLocalLocation(
                tz.getLocation(
                  tz_name,
                ),
              );
              print(
                'Timezone set to: $tz_name (matched from $timeZoneName)',
              );
              found = true;
              break;
            } catch (
              e
            ) {
              continue;
            }
          }
        }

        if (!found) {
          print(
            'No matching timezone found, falling back to UTC',
          );
          tz.setLocalLocation(
            tz.UTC,
          );
        }
      }
    } catch (
      e
    ) {
      print(
        'Error getting timezone: $e, using UTC',
      );
      tz.setLocalLocation(
        tz.UTC,
      );
    }

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse:
          (
            NotificationResponse response,
          ) {
            // Handle notification tap
            print(
              'Notification tapped: ${response.payload}',
            );
          },
    );

    if (Platform.isAndroid) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      print(
        'Android notifications permission requested',
      );
    }

    if (Platform.isIOS) {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      print(
        'iOS notifications permission result: $result',
      );
    }
  }

  // Schedule a notification to be shown at a specific date/time (with multiple fallback strategies)
  Future<
    void
  >
  scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // If the time is in the past, don't schedule
    if (scheduledTime.isBefore(
      DateTime.now(),
    )) {
      print(
        'Notification time is in the past, skipping. ID: $id, Time: $scheduledTime',
      );
      return;
    }

    try {
      final tzDateTime = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );
      print(
        'Scheduling notification - ID: $id, Title: $title, Scheduled for: $tzDateTime (${scheduledTime.difference(DateTime.now()).inMinutes} minutes from now)',
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminders',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print(
        'Notification scheduled successfully - ID: $id',
      );
    } catch (
      e
    ) {
      print(
        'Error scheduling notification with exact mode: $e',
      );
      // Fallback to imprecise scheduling if exact scheduling fails
      try {
        final tzDateTime = tz.TZDateTime.from(
          scheduledTime,
          tz.local,
        );
        print(
          'Attempting fallback scheduling for ID: $id',
        );
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tzDateTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_reminders',
              'Task Reminders',
              channelDescription: 'Notifications for task reminders',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        print(
          'Notification scheduled with fallback mode - ID: $id',
        );
      } catch (
        fallbackError
      ) {
        print(
          'Error scheduling notification with fallback: $fallbackError',
        );
        // Try simple notification as last resort
        try {
          print(
            'Attempting simple notification scheduling for ID: $id',
          );
          await _notificationsPlugin.show(
            id,
            title,
            body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'task_reminders',
                'Task Reminders',
                channelDescription: 'Notifications for task reminders',
              ),
            ),
          );
          print(
            'Simple notification shown - ID: $id',
          );
        } catch (
          simpleError
        ) {
          print(
            'Error with simple notification: $simpleError',
          );
        }
      }
    }
  }

  // Cancel a scheduled notification by ID
  Future<
    void
  >
  cancelNotification(
    int id,
  ) async {
    await _notificationsPlugin.cancel(
      id,
    );
  }
}
