import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_priority.dart';

class TaskController
    extends
        ChangeNotifier {
  final List<
    Task
  >
  _allTasks = [
    Task(
      id: '1',
      title: 'Complete project proposal',
      description: 'Write and submit the Q2 project proposal',
      dueDate: DateTime.now(),
      priority: TaskPriority.high,
      isCompleted: false,
      category: 'Work',
    ),
    Task(
      id: '2',
      title: 'Buy groceries',
      description: 'Milk, eggs, bread, vegetables',
      dueDate: DateTime.now().add(
        const Duration(
          days: 1,
        ),
      ),
      priority: TaskPriority.medium,
      isCompleted: false,
      category: 'Shopping',
    ),
    Task(
      id: '3',
      title: 'Call mom',
      dueDate: DateTime.now().add(
        const Duration(
          days: 2,
        ),
      ),
      priority: TaskPriority.low,
      isCompleted: false,
      category: 'Personal',
    ),
    Task(
      id: '4',
      title: 'Prepare presentation slides',
      dueDate: DateTime.now().add(
        const Duration(
          days: 1,
        ),
      ),
      priority: TaskPriority.high,
      isCompleted: false,
      category: 'Work',
    ),
  ];

  String
  _selectedCategory = 'All';

  String
  get selectedCategory => _selectedCategory;
  List<
    Task
  >
  get allTasks => _allTasks;

  List<
    Task
  >
  get pendingTasks {
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

    return filtered;
  }

  void
  setCategory(
    String category,
  ) {
    _selectedCategory = category;
    notifyListeners();
  }

  void
  toggleTaskCompletion(
    String taskId,
    bool isCompleted,
  ) {
    final taskIndex = _allTasks.indexWhere(
      (
        task,
      ) =>
          task.id ==
          taskId,
    );
    if (taskIndex !=
        -1) {
      _allTasks[taskIndex] = _allTasks[taskIndex].copyWith(
        isCompleted: isCompleted,
      );
      notifyListeners();
    }
  }

  void
  deleteTask(
    String taskId,
  ) {
    _allTasks.removeWhere(
      (
        task,
      ) =>
          task.id ==
          taskId,
    );
    notifyListeners();
  }

  void
  addTask(
    Task task,
  ) {
    _allTasks.add(
      task,
    );
    notifyListeners();
  }

  void
  updateTask(
    String taskId,
    Task updatedTask,
  ) {
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
      notifyListeners();
    }
  }
}
