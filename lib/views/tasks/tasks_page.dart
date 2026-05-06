import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_strings.dart';
import '../../controllers/task_controller.dart';
import 'widgets/task_card.dart';
import 'widgets/task_filter_chips.dart';
import 'widgets/add_task_dialog.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, _) {
        final pendingTasks = taskController.pendingTasks;
        final completedTasks = taskController.completedTasks;

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top + 8,
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.tasks,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You have ${pendingTasks.length} pending ${pendingTasks.length == 1 ? 'task' : 'tasks'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    onChanged: (value) => taskController.setSearchQuery(value),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TaskFilterChips(
                  onCategoryChanged: (category) {
                    taskController.setCategory(category);
                  },
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      if (pendingTasks.isEmpty && completedTasks.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 64),
                              Icon(
                                Icons.check_circle_outline,
                                size: 64,
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.noPendingTasks,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        ...pendingTasks.map((task) => TaskCard(
                              task: task,
                              onDelete: () => taskController.deleteTask(task.id),
                              onToggleComplete: (isCompleted) {
                                taskController.toggleTaskCompletion(
                                  task.id,
                                  isCompleted,
                                );
                                if (isCompleted) {
                                  _confettiController.play();
                                }
                              },
                              onPin: () => taskController.toggleTaskPin(task.id),
                              onFocus: () =>
                                  taskController.toggleTaskFocus(task.id),
                              isFocused:
                                  taskController.focusedTaskId == task.id,
                            )),
                        if (completedTasks.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Divider(),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Completed Tasks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...completedTasks.map((task) => Opacity(
                                opacity: 0.6,
                                child: TaskCard(
                                  task: task,
                                  onDelete: () =>
                                      taskController.deleteTask(task.id),
                                  onToggleComplete: (isCompleted) =>
                                      taskController.toggleTaskCompletion(
                                    task.id,
                                    isCompleted,
                                  ),
                                ),
                              )),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Add Task Button (Floating at the bottom)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddTaskDialog(),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text(AppStrings.addNewTask),
              ),
            ),

            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.accent,
                Colors.green,
                Colors.yellow,
              ],
            ),
          ],
        );
      },
    );
  }
}
