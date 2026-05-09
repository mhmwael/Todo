import 'task_priority.dart';

// Task model representing a to-do item with metadata for priority, completion, and scheduling
class Task {
  final String
  id; // Unique identifier
  final String
  title; // Task name
  final String?
  description; // Optional detailed description
  final DateTime
  dueDate; // When task should be completed
  final TaskPriority
  priority; // Priority level (High/Medium/Low)
  final bool
  isCompleted; // Completion status
  final String
  category; // Category for organization
  final bool
  isPinned; // Pinned status for quick access
  final DateTime?
  createdAt; // Creation timestamp
  final DateTime?
  updatedAt; // Last update timestamp

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.category,
    this.isPinned = false,
    this.createdAt,
    this.updatedAt,
  });

  Task
  copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    String? category,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id:
          id ??
          this.id,
      title:
          title ??
          this.title,
      description:
          description ??
          this.description,
      dueDate:
          dueDate ??
          this.dueDate,
      priority:
          priority ??
          this.priority,
      isCompleted:
          isCompleted ??
          this.isCompleted,
      category:
          category ??
          this.category,
      isPinned:
          isPinned ??
          this.isPinned,
      createdAt:
          createdAt ??
          this.createdAt,
      updatedAt:
          updatedAt ??
          this.updatedAt,
    );
  }
}
