import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../controllers/task_controller.dart';

class TaskTimePeriodFilter
    extends
        StatefulWidget {
  const TaskTimePeriodFilter({
    super.key,
  });

  @override
  State<
    TaskTimePeriodFilter
  >
  createState() => _TaskTimePeriodFilterState();
}

class _TaskTimePeriodFilterState
    extends
        State<
          TaskTimePeriodFilter
        > {
  late String
  selectedTimePeriod;

  @override
  void
  initState() {
    super.initState();
    selectedTimePeriod = 'All';
  }

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
            child,
          ) {
            final timePeriods = [
              'All',
              'Daily',
              'Weekly',
              'Monthly',
            ];

            return SizedBox(
              height: 56,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 0,
                    children:
                        List<
                          Widget
                        >.generate(
                          timePeriods.length,
                          (
                            int index,
                          ) {
                            final period = timePeriods[index];
                            final isSelected =
                                selectedTimePeriod ==
                                period;
                            return FilterChip(
                              label: Text(
                                period,
                              ),
                              selected: isSelected,
                              onSelected:
                                  (
                                    bool value,
                                  ) {
                                    setState(
                                      () {
                                        selectedTimePeriod = period;
                                      },
                                    );
                                    taskController.setTimePeriod(
                                      period,
                                    );
                                  },
                              backgroundColor:
                                  Theme.of(
                                        context,
                                      ).brightness ==
                                      Brightness.dark
                                  ? const Color(
                                      0xFF1E1E1E,
                                    )
                                  : AppColors.surface,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (Theme.of(
                                                context,
                                              ).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : AppColors.textPrimary),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.divider,
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ),
              ),
            );
          },
    );
  }
}
