import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/user_stats.dart';

class ProfileController
    extends
        ChangeNotifier {
  static const String
  _imageKey = 'profile_image_path';
  static const String
  _loginKey = 'is_logged_in';

  UserStats
  _stats = const UserStats(
    completedCount: 0,
    totalCount: 0,
    streak: 0,
  );

  String?
  _profileImagePath;
  bool
  _isLoggedIn = false;
  String
  _userName = 'Guest User';

  ProfileController() {
    _loadProfile();
  }

  UserStats
  get stats => _stats;
  String?
  get profileImagePath => _profileImagePath;
  bool
  get isLoggedIn => _isLoggedIn;
  String
  get userName => _userName;

  Future<
    void
  >
  _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _profileImagePath = prefs.getString(
      _imageKey,
    );
    _isLoggedIn =
        prefs.getBool(
          _loginKey,
        ) ??
        false;
    if (_isLoggedIn) {
      _userName = 'Jules Engineer';
    }
    notifyListeners();
  }

  Future<
    void
  >
  setProfileImage(
    String path,
  ) async {
    _profileImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _imageKey,
      path,
    );
    notifyListeners();
  }

  Future<
    void
  >
  login() async {
    _isLoggedIn = true;
    _userName = 'Jules Engineer';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _loginKey,
      true,
    );
    notifyListeners();
  }

  Future<
    void
  >
  logout() async {
    _isLoggedIn = false;
    _userName = 'Guest User';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      _loginKey,
      false,
    );
    notifyListeners();
  }

  void
  updateStats(
    List<
      Task
    >
    allTasks,
  ) {
    final completedCount = allTasks
        .where(
          (
            task,
          ) => task.isCompleted,
        )
        .length;
    final totalCount = allTasks.length;

    _stats = UserStats(
      completedCount: completedCount,
      totalCount: totalCount,
      streak: _calculateStreak(
        allTasks,
      ),
    );
    notifyListeners();
  }

  int
  _calculateStreak(
    List<
      Task
    >
    allTasks,
  ) {
    final today = DateTime.now();
    int streak = 0;

    for (
      int i = 0;
      i <
          365;
      i++
    ) {
      final date = today.subtract(
        Duration(
          days: i,
        ),
      );
      final tasksForDay = allTasks.where(
        (
          task,
        ) {
          return task.dueDate.year ==
                  date.year &&
              task.dueDate.month ==
                  date.month &&
              task.dueDate.day ==
                  date.day &&
              task.isCompleted;
        },
      );

      if (tasksForDay.isEmpty) {
        break;
      }
      streak++;
    }

    return streak;
  }

  double
  getCompletionPercentage() {
    if (_stats.totalCount ==
        0)
      return 0;
    return (_stats.completedCount /
            _stats.totalCount) *
        100;
  }
}
