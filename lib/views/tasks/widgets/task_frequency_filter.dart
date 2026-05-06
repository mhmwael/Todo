import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/task_frequency.dart';

class TaskFrequencyFilter
    extends
        StatefulWidget {
  final ValueChanged<
    TaskFrequency
  >
  onFrequencyChanged;

  const TaskFrequencyFilter({
    super.key,
    required this.onFrequencyChanged,
  });

  @override
  State<
    TaskFrequencyFilter
  >
  createState() => _TaskFrequencyFilterState();
}

class _TaskFrequencyFilterState
    extends
        State<
          TaskFrequencyFilter
        > {
  late TaskFrequency
  selectedFrequency;

  @override
  void
  initState() {
    super.initState();
    selectedFrequency = TaskFrequency.none;
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    final frequencies = [
      TaskFrequency.none,
      TaskFrequency.daily,
      TaskFrequency.weekly,
      TaskFrequency.monthly,
    ];

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
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
                        frequencies.length,
                        (
                          int index,
                        ) {
                          final frequency = frequencies[index];
                          final isSelected =
                              selectedFrequency ==
                              frequency;
                          return FilterChip(
                            label: Text(
                              frequency.displayName,
                            ),
                            selected: isSelected,
                            onSelected:
                                (
                                  bool value,
                                ) {
                                  setState(
                                    () {
                                      selectedFrequency = frequency;
                                    },
                                  );
                                  widget.onFrequencyChanged(
                                    frequency,
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
          ),
        ],
      ),
    );
  }
}
