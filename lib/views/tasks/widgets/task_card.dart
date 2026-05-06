import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/task.dart';
import '../../../models/task_priority.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback? onPin;
  final VoidCallback? onFocus;
  final VoidCallback? onEdit;
  final bool isFocused;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggleComplete,
    this.onPin,
    this.onFocus,
    this.onEdit,
    this.isFocused = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: GestureDetector(
        onTap: widget.onEdit,
        child: Padding(
          padding: const EdgeInsets.all(
            12.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Checkbox(
              value: widget.task.isCompleted,
              onChanged: (bool? value) {
                if (value != null) {
                  widget.onToggleComplete(value);
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
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        decoration: widget.task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(widget.task.priority)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.task.priority.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getPriorityColor(widget.task.priority),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.task.category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          _formatDate(widget.task.dueDate),
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
            if (widget.onFocus != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  widget.isFocused
                      ? Icons.center_focus_strong
                      : Icons.center_focus_weak,
                  color: widget.isFocused ? AppColors.primary : Colors.grey,
                ),
                onPressed: widget.onFocus,
                iconSize: 20,
              ),
            if (widget.onPin != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  widget.task.isPinned
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  color: widget.task.isPinned ? AppColors.primary : Colors.grey,
                ),
                onPressed: widget.onPin,
                iconSize: 20,
              ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
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
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.highPriority;
      case TaskPriority.medium:
        return AppColors.mediumPriority;
      case TaskPriority.low:
        return AppColors.lowPriority;
    }
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final timeStr = TimeOfDay.fromDateTime(date).format(context);

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today $timeStr';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow $timeStr';
    } else {
      return '${date.month}/${date.day}/${date.year} $timeStr';
    }
  }
}
