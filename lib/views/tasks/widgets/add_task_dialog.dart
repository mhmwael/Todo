import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/task_controller.dart';
import '../../../models/task.dart';
import '../../../models/task_priority.dart';
import '../../../core/theme/app_colors.dart';

class AddTaskDialog
    extends
        StatefulWidget {
  final DateTime?
  initialDate;

  const AddTaskDialog({
    super.key,
    this.initialDate,
  });

  @override
  State<
    AddTaskDialog
  >
  createState() => _AddTaskDialogState();
}

class _AddTaskDialogState
    extends
        State<
          AddTaskDialog
        > {
  late TextEditingController
  titleController;
  late TextEditingController
  descriptionController;
  late DateTime
  selectedDate;
  TaskPriority
  selectedPriority = TaskPriority.medium;
  String
  selectedCategory = 'Work';

  final categories = [
    'Work',
    'Personal',
    'Shopping',
  ];

  @override
  void
  initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
    selectedDate =
        widget.initialDate ??
        DateTime.now();
  }

  @override
  void
  dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: RepaintBoundary(
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          16,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Task',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 24,
              ),
              // Title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Task title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              // Description
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Task description (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(
                height: 16,
              ),
              // Category
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.divider),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    alignment: Alignment.center,
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : AppColors.surface,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    elevation: 8,
                    menuMaxHeight: 250,
                    selectedItemBuilder: (BuildContext context) {
                      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
                      return categories.map<Widget>((String category) {
                        return Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    items: categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedCategory == category
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  category,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: selectedCategory == category
                                        ? AppColors.primary
                                        : (Theme.of(context).brightness == Brightness.dark
                                            ? Colors.white
                                            : AppColors.textPrimary),
                                    fontSize: 16,
                                    fontWeight: selectedCategory == category
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              // Priority
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: TaskPriority.values
                        .map(
                          (
                            priority,
                          ) => Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(
                                  () {
                                    selectedPriority = priority;
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(
                                  8,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      selectedPriority ==
                                          priority
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  border: Border.all(
                                    color: AppColors.primary,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    priority
                                        .toString()
                                        .split(
                                          '.',
                                        )[1]
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color:
                                          selectedPriority ==
                                              priority
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              // Due Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium,
                  ),
                  ElevatedButton(
                    onPressed: _selectDate,
                    child: const Text(
                      'Date',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.highPriority,
                      ),
                      onPressed: () => Navigator.pop(
                        context,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          final newTask = Task(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text,
                            description: descriptionController.text.isEmpty
                                ? null
                                : descriptionController.text,
                            dueDate: selectedDate,
                            priority: selectedPriority,
                            isCompleted: false,
                            category: selectedCategory,
                          );

                          context
                              .read<
                                TaskController
                              >()
                              .addTask(
                                newTask,
                              );

                          Navigator.pop(
                            context,
                          );

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Task added successfully!',
                              ),
                              duration: Duration(
                                seconds: 2,
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Add Task',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
