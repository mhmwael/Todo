import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/user_stats.dart';

class ProfileController extends ChangeNotifier {
  UserStats _stats = const UserStats(
    completedCount: 0,
    totalCount: 0,
    streak: 0,
  );

  String? _profileImagePath;
  File? _profileImageFile;
  bool _isLoggedIn = false;
  String _userName = 'Guest User';

  UserStats get stats => _stats;
  String? get profileImagePath => _profileImagePath;
  File? get profileImageFile => _profileImageFile;
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;

  void setProfileImage(String path) {
    _profileImagePath = path;
    _profileImageFile = null;
    notifyListeners();
  }

  void setProfileImageFile(File file) {
    _profileImageFile = file;
    _profileImagePath = null;
    notifyListeners();
  }

  void login() {
    _isLoggedIn = true;
    _userName = 'Jules Engineer';
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = 'Guest User';
    notifyListeners();
  }

  void updateStats(List<Task> allTasks) {
    final completedCount = allTasks.where((task) => task.isCompleted).length;
    final totalCount = allTasks.length;

    _stats = UserStats(
      completedCount: completedCount,
      totalCount: totalCount,
      streak: _calculateStreak(allTasks),
    );
    notifyListeners();
  }

  int _calculateStreak(List<Task> allTasks) {
    final today = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final date = today.subtract(Duration(days: i));
      final tasksForDay = allTasks.where((task) {
        return task.dueDate.year == date.year &&
            task.dueDate.month == date.month &&
            task.dueDate.day == date.day &&
            task.isCompleted;
      });

      if (tasksForDay.isEmpty) {
        break;
      }
      streak++;
    }

    return streak;
  }

  double getCompletionPercentage() {
    if (_stats.totalCount == 0) return 0;
    return (_stats.completedCount / _stats.totalCount) * 100;
  }
}
