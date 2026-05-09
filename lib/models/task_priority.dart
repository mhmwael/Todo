// Enum for task priority levels with helper methods for display and storage
enum TaskPriority {
  low, // Low priority (green)
  medium, // Medium priority (orange)
  high, // High priority (red)
}

// Extension providing string labels and integer values for priority levels
extension TaskPriorityExtension
    on
        TaskPriority {
  // Get user-friendly priority label
  String
  get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  int
  get value {
    switch (this) {
      case TaskPriority.low:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.high:
        return 2;
    }
  }
}
