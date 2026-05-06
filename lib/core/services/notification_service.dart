import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io'
    show
        Platform;

class NotificationService {
  static final NotificationService
  _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin
  _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<
    void
  >
  init() async {
    tz.initializeTimeZones();
    final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).toString();
    try {
      tz.setLocalLocation(
        tz.getLocation(
          timeZoneName,
        ),
      );
    } catch (
      e
    ) {
      // Fallback to UTC if the timezone is not found
      tz.setLocalLocation(
        tz.UTC,
      );
    }

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
    );

    if (Platform.isAndroid) {
      _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

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
    ))
      return;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

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
