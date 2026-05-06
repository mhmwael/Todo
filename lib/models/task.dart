import 'task_priority.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final String category;
  final bool isPinned;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.category,
    this.isPinned = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    String? category,
    bool? isPinned,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}
