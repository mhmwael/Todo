import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../core/database/task_database_service.dart';

class TaskController extends ChangeNotifier {
  final TaskDatabaseService _dbService = TaskDatabaseService();
  List<Task> _allTasks = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  TaskController() {
    _loadTasks();
  }

  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  List<Task> get allTasks => _allTasks;

  Future<void> _loadTasks() async {
    _allTasks = await _dbService.getAllTasks();
    notifyListeners();
  }

  List<Task> get pendingTasks {
    List<Task> filtered = _allTasks.where((task) => !task.isCompleted).toList();
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((task) => task.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (task.description?.toLowerCase() ?? '')
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return filtered;
  }

  List<Task> get completedTasks {
    List<Task> filtered = _allTasks.where((task) => task.isCompleted).toList();
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((task) => task.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (task.description?.toLowerCase() ?? '')
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }
    // Sort by due date or completion time if available, but for now just reverse to show latest first
    filtered.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    return filtered.take(20).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final updatedTask = _allTasks[taskIndex].copyWith(isCompleted: isCompleted);
      _allTasks[taskIndex] = updatedTask;
      await _dbService.updateTask(updatedTask);

      if (isCompleted) {
        await _enforceCompletedTasksLimit();
      }

      notifyListeners();
    }
  }

  Future<void> _enforceCompletedTasksLimit() async {
    final completed = _allTasks.where((t) => t.isCompleted).toList();
    if (completed.length > 20) {
      completed.sort((a, b) => a.dueDate.compareTo(b.dueDate)); // Oldest first
      final toDeleteCount = completed.length - 20;
      for (int i = 0; i < toDeleteCount; i++) {
        await deleteTask(completed[i].id);
      }
    }
  }

  Future<void> deleteTask(String taskId) async {
    _allTasks.removeWhere((task) => task.id == taskId);
    await _dbService.deleteTask(taskId);
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _allTasks.add(task);
    await _dbService.addTask(task);
    notifyListeners();
  }

  Future<void> updateTask(String taskId, Task updatedTask) async {
    final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _allTasks[taskIndex] = updatedTask;
      await _dbService.updateTask(updatedTask);
      notifyListeners();
    }
  }
}
