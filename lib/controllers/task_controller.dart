import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../core/database/task_database_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/firebase_auth_service.dart';
import '../core/services/firebase_task_service.dart';

class TaskController
    extends
        ChangeNotifier {
  final NotificationService
  _notificationService = NotificationService();
  final TaskDatabaseService
  _dbService = TaskDatabaseService();
  final FirebaseAuthService
  _authService = FirebaseAuthService();
  final FirebaseTaskService
  _firebaseTaskService = FirebaseTaskService();

  List<
    Task
  >
  _allTasks = [];
  String
  _selectedCategory = 'All';
  String
  _searchQuery = '';
  String?
  _focusedTaskId;
  String
  _selectedTimePeriod = 'All';
  bool
  _isSyncing = false;

  TaskController() {
    _loadTasks();
    _listenToAuthChanges();
  }

  String
  get selectedCategory => _selectedCategory;
  String
  get searchQuery => _searchQuery;
  String?
  get focusedTaskId => _focusedTaskId;
  String
  get selectedTimePeriod => _selectedTimePeriod;
  List<
    Task
  >
  get allTasks => _allTasks;
  bool
  get isSyncing => _isSyncing;

  void
  _listenToAuthChanges() {
    _authService.authStateChanges.listen(
      (
        user,
      ) {
        if (user !=
            null) {
          syncTasksFromFirebase();
        } else {
          _loadTasks();
        }
      },
    );
  }

  Future<
    void
  >
  syncTasksFromFirebase() async {
    if (!_authService.isLoggedIn) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final userId = _authService.getUserId()!;
      final firebaseTasks = await _firebaseTaskService.getUserTasks(
        userId,
      );

      _allTasks = firebaseTasks;

      // Also update local database
      for (var task in firebaseTasks) {
        await _dbService.addTask(
          task,
        );
      }

      notifyListeners();
    } catch (
      e
    ) {
      print(
        'Error syncing tasks from Firebase: $e',
      );
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  bool
  _isTaskInTimePeriod(
    Task task,
    String timePeriod,
  ) {
    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );
    final taskDate = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    );

    switch (timePeriod) {
      case 'Daily':
        return taskDate.year ==
                today.year &&
            taskDate.month ==
                today.month &&
            taskDate.day ==
                today.day;
      case 'Weekly':
        final weekStart = today.subtract(
          Duration(
            days:
                today.weekday -
                1,
          ),
        );
        final weekEnd = weekStart.add(
          const Duration(
            days: 6,
          ),
        );
        return (taskDate.isAfter(
                  weekStart.subtract(
                    const Duration(
                      days: 1,
                    ),
                  ),
                ) ||
                taskDate.isAtSameMomentAs(
                  weekStart,
                )) &&
            (taskDate.isBefore(
                  weekEnd.add(
                    const Duration(
                      days: 1,
                    ),
                  ),
                ) ||
                taskDate.isAtSameMomentAs(
                  weekEnd,
                ));
      case 'Monthly':
        return task.dueDate.year ==
                now.year &&
            task.dueDate.month ==
                now.month;
      default:
        return true;
    }
  }

  Future<
    void
  >
  _loadTasks() async {
    _allTasks = await _dbService.getAllTasks();
    notifyListeners();
  }

  List<
    Task
  >
  get pendingTasks {
    if (_focusedTaskId !=
        null) {
      return _allTasks
          .where(
            (
              task,
            ) =>
                task.id ==
                _focusedTaskId,
          )
          .toList();
    }

    List<
      Task
    >
    filtered = _allTasks
        .where(
          (
            task,
          ) => !task.isCompleted,
        )
        .toList();
    if (_selectedCategory !=
        'All') {
      filtered = filtered
          .where(
            (
              task,
            ) =>
                task.category ==
                _selectedCategory,
          )
          .toList();
    }
    if (_selectedTimePeriod !=
        'All') {
      filtered = filtered
          .where(
            (
              task,
            ) => _isTaskInTimePeriod(
              task,
              _selectedTimePeriod,
            ),
          )
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (
              task,
            ) =>
                task.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (task.description?.toLowerCase() ??
                        '')
                    .contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }

    // Sort: pinned first, then by date
    filtered.sort(
      (
        a,
        b,
      ) {
        if (a.isPinned &&
            !b.isPinned)
          return -1;
        if (!a.isPinned &&
            b.isPinned)
          return 1;
        return a.dueDate.compareTo(
          b.dueDate,
        );
      },
    );

    return filtered;
  }

  List<
    Task
  >
  get completedTasks {
    if (_focusedTaskId !=
        null)
      return [];

    List<
      Task
    >
    filtered = _allTasks
        .where(
          (
            task,
          ) => task.isCompleted,
        )
        .toList();
    if (_selectedCategory !=
        'All') {
      filtered = filtered
          .where(
            (
              task,
            ) =>
                task.category ==
                _selectedCategory,
          )
          .toList();
    }
    if (_selectedTimePeriod !=
        'All') {
      filtered = filtered
          .where(
            (
              task,
            ) => _isTaskInTimePeriod(
              task,
              _selectedTimePeriod,
            ),
          )
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (
              task,
            ) =>
                task.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (task.description?.toLowerCase() ??
                        '')
                    .contains(
                      _searchQuery.toLowerCase(),
                    ),
          )
          .toList();
    }
    // Sort by due date or completion time if available, but for now just reverse to show latest first
    filtered.sort(
      (
        a,
        b,
      ) => b.dueDate.compareTo(
        a.dueDate,
      ),
    );
    return filtered
        .take(
          20,
        )
        .toList();
  }

  void
  setCategory(
    String category,
  ) {
    _selectedCategory = category;
    notifyListeners();
  }

  void
  setTimePeriod(
    String timePeriod,
  ) {
    _selectedTimePeriod = timePeriod;
    notifyListeners();
  }

  void
  setSearchQuery(
    String query,
  ) {
    _searchQuery = query;
    notifyListeners();
  }

  void
  toggleTaskPin(
    String taskId,
  ) async {
    final taskIndex = _allTasks.indexWhere(
      (
        task,
      ) =>
          task.id ==
          taskId,
    );
    if (taskIndex !=
        -1) {
      final updatedTask = _allTasks[taskIndex].copyWith(
        isPinned: !_allTasks[taskIndex].isPinned,
      );
      _allTasks[taskIndex] = updatedTask;
      await _dbService.updateTask(
        updatedTask,
      );
      notifyListeners();
    }
  }

  void
  toggleTaskFocus(
    String taskId,
  ) {
    if (_focusedTaskId ==
        taskId) {
      _focusedTaskId = null;
    } else {
      _focusedTaskId = taskId;
    }
    notifyListeners();
  }

  Future<
    void
  >
  toggleTaskCompletion(
    String taskId,
    bool isCompleted,
  ) async {
    final taskIndex = _allTasks.indexWhere(
      (
        task,
      ) =>
          task.id ==
          taskId,
    );
    if (taskIndex !=
        -1) {
      final updatedTask = _allTasks[taskIndex].copyWith(
        isCompleted: isCompleted,
      );
      _allTasks[taskIndex] = updatedTask;
      await _dbService.updateTask(
        updatedTask,
      );

      if (isCompleted) {
        await _enforceCompletedTasksLimit();
        _notificationService.cancelNotification(
          int.parse(
            taskId.substring(
              taskId.length -
                  9,
            ),
          ),
        );
      } else {
        _scheduleTaskNotification(
          updatedTask,
        );
      }

      notifyListeners();
    }
  }

  Future<
    void
  >
  _enforceCompletedTasksLimit() async {
    final completed = _allTasks
        .where(
          (
            t,
          ) => t.isCompleted,
        )
        .toList();
    if (completed.length >
        20) {
      completed.sort(
        (
          a,
          b,
        ) => a.dueDate.compareTo(
          b.dueDate,
        ),
      ); // Oldest first
      final toDeleteCount =
          completed.length -
          20;
      for (
        int i = 0;
        i <
            toDeleteCount;
        i++
      ) {
        await deleteTask(
          completed[i].id,
        );
      }
    }
  }

  Future<
    void
  >
  deleteTask(
    String taskId,
  ) async {
    _allTasks.removeWhere(
      (
        task,
      ) =>
          task.id ==
          taskId,
    );
    await _dbService.deleteTask(
      taskId,
    );

    // Sync to Firebase if logged in
    if (_authService.isLoggedIn) {
      try {
        final userId = _authService.getUserId()!;
        await _firebaseTaskService.deleteTask(
          userId,
          taskId,
        );
      } catch (
        e
      ) {
        print(
          'Error syncing task deletion to Firebase: $e',
        );
      }
    }

    _notificationService.cancelNotification(
      int.parse(
        taskId.substring(
          taskId.length -
              9,
        ),
      ),
    );
    notifyListeners();
  }

  Future<
    void
  >
  addTask(
    Task task,
  ) async {
    _allTasks.add(
      task,
    );
    await _dbService.addTask(
      task,
    );

    // Sync to Firebase if logged in
    if (_authService.isLoggedIn) {
      try {
        final userId = _authService.getUserId()!;
        await _firebaseTaskService.addTask(
          userId,
          task,
        );
      } catch (
        e
      ) {
        print(
          'Error syncing new task to Firebase: $e',
        );
      }
    }

    _scheduleTaskNotification(
      task,
    );
    notifyListeners();
  }

  Future<
    void
  >
  updateTask(
    String taskId,
    Task updatedTask,
  ) async {
    final taskIndex = _allTasks.indexWhere(
      (
        task,
      ) =>
          task.id ==
          taskId,
    );
    if (taskIndex !=
        -1) {
      _allTasks[taskIndex] = updatedTask;
      await _dbService.updateTask(
        updatedTask,
      );

      // Sync to Firebase if logged in
      if (_authService.isLoggedIn) {
        try {
          final userId = _authService.getUserId()!;
          await _firebaseTaskService.updateTask(
            userId,
            updatedTask,
          );
        } catch (
          e
        ) {
          print(
            'Error syncing task update to Firebase: $e',
          );
        }
      }

      _scheduleTaskNotification(
        updatedTask,
      );
      notifyListeners();
    }
  }

  void
  _scheduleTaskNotification(
    Task task,
  ) {
    if (!task.isCompleted &&
        task.dueDate.isAfter(
          DateTime.now(),
        )) {
      _notificationService.scheduleNotification(
        id: int.parse(
          task.id.substring(
            task.id.length -
                9,
          ),
        ),
        title: 'Task Reminder',
        body: task.title,
        scheduledTime: task.dueDate,
      );
    }
  }
}
