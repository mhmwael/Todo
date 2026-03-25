import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/task.dart';
import '../../../models/task_priority.dart';

class TaskCard
    extends
        StatefulWidget {
  final Task
  task;
  final VoidCallback
  onDelete;
  final ValueChanged<
    bool
  >
  onToggleComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  State<
    TaskCard
  >
  createState() => _TaskCardState();
}

class _TaskCardState
    extends
        State<
          TaskCard
        > {
  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: widget.task.isCompleted,
              onChanged:
                  (
                    bool? value,
                  ) {
                    if (value !=
                        null) {
                      widget.onToggleComplete(
                        value,
                      );
                    }
                  },
              activeColor: AppColors.primary,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration: widget.task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getPriorityColor(
                                  widget.task.priority,
                                ).withOpacity(
                                  0.2,
                                ),
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: Text(
                            widget.task.priority.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(
                                widget.task.priority,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(
                              0.2,
                            ),
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: Text(
                            widget.task.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(
                            widget.task.dueDate,
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
              ),
              color: Colors.red,
              onPressed: widget.onDelete,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color
  _getPriorityColor(
    TaskPriority priority,
  ) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.highPriority;
      case TaskPriority.medium:
        return AppColors.mediumPriority;
      case TaskPriority.low:
        return AppColors.lowPriority;
    }
  }

  String
  _formatDate(
    DateTime date,
  ) {
    final today = DateTime.now();
    final tomorrow = today.add(
      const Duration(
        days: 1,
      ),
    );

    if (date.year ==
            today.year &&
        date.month ==
            today.month &&
        date.day ==
            today.day) {
      return 'Today';
    } else if (date.year ==
            tomorrow.year &&
        date.month ==
            tomorrow.month &&
        date.day ==
            tomorrow.day) {
      return 'Tomorrow';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
