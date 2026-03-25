import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_strings.dart';
import '../../controllers/task_controller.dart';
import 'widgets/task_card.dart';
import 'widgets/task_filter_chips.dart';

class TasksPage
    extends
        StatelessWidget {
  const TasksPage({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Consumer<
      TaskController
    >(
      builder:
          (
            context,
            taskController,
            _,
          ) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top padding for notification bar
                SizedBox(
                  height:
                      MediaQuery.of(
                        context,
                      ).padding.top +
                      8,
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tasks,
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'You have ${taskController.pendingTasks.length} pending ${taskController.pendingTasks.length == 1 ? 'task' : 'tasks'}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                // Category Filter Chips
                TaskFilterChips(
                  onCategoryChanged:
                      (
                        category,
                      ) {
                        taskController.setCategory(
                          category,
                        );
                      },
                ),

                const SizedBox(
                  height: 16,
                ),

                // Pending Tasks List
                Expanded(
                  child: taskController.pendingTasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: AppColors.primary.withOpacity(
                                  0.3,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                AppStrings.noPendingTasks,
                                style:
                                    Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: taskController.pendingTasks.length,
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final task = taskController.pendingTasks[index];
                                return TaskCard(
                                  task: task,
                                  onDelete: () => taskController.deleteTask(
                                    task.id,
                                  ),
                                  onToggleComplete:
                                      (
                                        isCompleted,
                                      ) => taskController.toggleTaskCompletion(
                                        task.id,
                                        isCompleted,
                                      ),
                                );
                              },
                        ),
                ),

                // Add Task Button
                Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Show add task bottom sheet
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        AppStrings.addNewTask,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }
}
