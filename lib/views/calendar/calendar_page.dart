import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/task.dart';
import '../../controllers/calendar_controller.dart';
import '../../controllers/task_controller.dart';
import '../tasks/widgets/task_card.dart';
import '../tasks/widgets/add_task_dialog.dart';

// Calendar view showing tasks organized by selected date
class CalendarPage
    extends
        StatelessWidget {
  const CalendarPage({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Consumer2<
      CalendarController,
      TaskController
    >(
      builder:
          (
            context,
            calendarController,
            taskController,
            _,
          ) {
            final selectedDate = calendarController.selectedDate;
            final tasksForDay = calendarController.getTasksForDay(
              (taskController.allTasks
                      as List)
                  .cast<
                    Task
                  >(),
              selectedDate,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: Text(
                    'Calendar',
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge,
                  ),
                ),
                // Month Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          final previousMonth = DateTime(
                            selectedDate.year,
                            selectedDate.month -
                                1,
                          );
                          calendarController.setSelectedDate(
                            previousMonth,
                          );
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(
                              2024,
                            ),
                            lastDate: DateTime(
                              2035,
                            ),
                            initialEntryMode: DatePickerEntryMode.calendarOnly,
                            builder:
                                (
                                  context,
                                  child,
                                ) {
                                  final isDarkMode =
                                      Theme.of(
                                        context,
                                      ).brightness ==
                                      Brightness.dark;
                                  return Theme(
                                    data:
                                        Theme.of(
                                          context,
                                        ).copyWith(
                                          colorScheme: isDarkMode
                                              ? const ColorScheme.dark(
                                                  primary: AppColors.primary,
                                                  onPrimary: Colors.white,
                                                  surface: Color(
                                                    0xFF1E1E1E,
                                                  ),
                                                  onSurface: Colors.white,
                                                )
                                              : const ColorScheme.light(
                                                  primary: AppColors.primary,
                                                  onPrimary: Colors.white,
                                                  surface: Colors.white,
                                                  onSurface: AppColors.textPrimary,
                                                ),
                                        ),
                                    child: RepaintBoundary(
                                      child: child!,
                                    ),
                                  );
                                },
                          );
                          if (picked !=
                              null) {
                            calendarController.setSelectedDate(
                              picked,
                            );
                          }
                        },
                        child: Text(
                          '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final nextMonth = DateTime(
                            selectedDate.year,
                            selectedDate.month +
                                1,
                          );
                          calendarController.setSelectedDate(
                            nextMonth,
                          );
                        },
                        icon: const Icon(
                          Icons.chevron_right,
                        ),
                      ),
                    ],
                  ),
                ),
                // Calendar Grid
                Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  child: _buildCalendarGrid(
                    context,
                    selectedDate,
                    (taskController.allTasks
                            as List)
                        .cast<
                          Task
                        >(),
                    calendarController,
                  ),
                ),
                // Tasks for Selected Day
                if (tasksForDay.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Text(
                      'Tasks for ${_getMonthName(selectedDate.month)} ${selectedDate.day}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge,
                    ),
                  ),
                Expanded(
                  child: tasksForDay.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks for this day',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          itemCount: tasksForDay.length,
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                final task = tasksForDay[index];
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
                Padding(
                  padding: const EdgeInsets.all(
                    16.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (
                                context,
                              ) => AddTaskDialog(
                                initialDate: selectedDate,
                              ),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Add Task',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
    );
  }

  Widget
  _buildCalendarGrid(
    BuildContext context,
    DateTime selectedDate,
    List<
      Task
    >
    allTasks,
    CalendarController calendarController,
  ) {
    final firstDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month +
          1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;
    // Only show markers for incomplete tasks
    final taskList = allTasks
        .where(
          (
            task,
          ) => !task.isCompleted,
        )
        .toList();

    return Column(
      children: [
        // Weekday headers
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            _WeekdayHeader(
              'Mon',
            ),
            _WeekdayHeader(
              'Tue',
            ),
            _WeekdayHeader(
              'Wed',
            ),
            _WeekdayHeader(
              'Thu',
            ),
            _WeekdayHeader(
              'Fri',
            ),
            _WeekdayHeader(
              'Sat',
            ),
            _WeekdayHeader(
              'Sun',
            ),
          ],
        ),
        // Calendar days
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount:
              daysInMonth +
              firstWeekday -
              1,
          itemBuilder:
              (
                context,
                index,
              ) {
                if (index <
                    firstWeekday -
                        1) {
                  return const SizedBox();
                }

                final day =
                    index -
                    (firstWeekday -
                        1) +
                    1;
                final date = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  day,
                );
                final tasksForDay = calendarController.getTasksForDay(
                  taskList,
                  date,
                );
                final hasTask = tasksForDay.isNotEmpty;
                final taskCount = tasksForDay.length;
                final isSelected =
                    date.year ==
                        selectedDate.year &&
                    date.month ==
                        selectedDate.month &&
                    date.day ==
                        selectedDate.day;
                final isToday =
                    date.year ==
                        DateTime.now().year &&
                    date.month ==
                        DateTime.now().month &&
                    date.day ==
                        DateTime.now().day;

                return GestureDetector(
                  onTap: () {
                    calendarController.setSelectedDate(
                      date,
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(
                          4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                              ? AppColors.primary.withOpacity(
                                  0.1,
                                )
                              : (Theme.of(
                                          context,
                                        ).brightness ==
                                        Brightness.dark
                                    ? const Color(
                                        0xFF1E1E1E,
                                      )
                                    : AppColors.surface),
                          border: hasTask
                              ? Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (Theme.of(
                                              context,
                                            ).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.textPrimary),
                              fontWeight: hasTask
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      if (hasTask)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFE53935,
                              ), // Red color
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                taskCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
        ),
      ],
    );
  }

  String
  _getMonthName(
    int month,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month -
        1];
  }
}

class _WeekdayHeader
    extends
        StatelessWidget {
  final String
  label;

  const _WeekdayHeader(
    this.label,
  );

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
