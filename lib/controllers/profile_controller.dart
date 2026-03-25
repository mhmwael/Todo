import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/user_stats.dart';

class ProfileController extends ChangeNotifier {
  UserStats _stats = const UserStats(
    completedCount: 0,
    totalCount: 0,
    streak: 0,
  );

  UserStats get stats => _stats;

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
