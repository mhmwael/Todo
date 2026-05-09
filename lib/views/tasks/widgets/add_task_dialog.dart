import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/task_controller.dart';
import '../../../controllers/category_controller.dart';
import '../../../models/task.dart';
import '../../../models/task_priority.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/speech_recognition_service.dart';

// Dialog for creating new tasks or editing existing ones with priority, category, and date selection
class AddTaskDialog
    extends
        StatefulWidget {
  final DateTime?
  initialDate; // Pre-selected date for new task
  final Task?
  task; // Task to edit (null for new task)

  const AddTaskDialog({
    super.key,
    this.initialDate,
    this.task,
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
  titleController; // Task title input
  late DateTime
  selectedDate; // Selected due date
  TaskPriority
  selectedPriority = TaskPriority.medium; // Priority level
  String?
  selectedCategory; // Category assignment

  final SpeechRecognitionService
  _speechService = SpeechRecognitionService(); // Voice input
  bool
  _isListening = false; // Voice input status

  @override
  void
  initState() {
    super.initState();
    titleController = TextEditingController(
      text: widget.task?.title,
    );
    selectedDate =
        widget.task?.dueDate ??
        widget.initialDate ??
        DateTime.now();
    selectedPriority =
        widget.task?.priority ??
        TaskPriority.medium;
    selectedCategory = widget.task?.category;
    _initSpeech();
  }

  Future<
    void
  >
  _initSpeech() async {
    await _speechService.initialize();
  }

  Future<
    void
  >
  _startListeningToSpeech() async {
    if (_isListening) return;

    print(
      '=== START LISTENING DEBUG ===',
    );
    setState(
      () {
        _isListening = true;
      },
    );

    try {
      // Make sure it's initialized before listening
      print(
        'Initializing speech service...',
      );
      final isInitialized = await _speechService.initialize();
      print(
        'Speech service initialized: $isInitialized',
      );

      if (!isInitialized) {
        throw Exception(
          'Speech recognition not available on this device',
        );
      }

      print(
        'Starting to listen for speech...',
      );
      final result = await _speechService.startListening();
      print(
        'Speech result received: "$result"',
      );

      if (result !=
              null &&
          result.isNotEmpty) {
        print(
          'Setting title controller text to: "$result"',
        );
        if (mounted) {
          setState(
            () {
              titleController.text = result;
              print(
                'Title controller text set. Value: "${titleController.text}"',
              );
            },
          );
        }
      } else {
        print(
          'Result is null or empty. Result: "$result"',
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            const SnackBar(
              content: Text(
                'No speech recognized. Please try again and speak clearly.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(
                seconds: 2,
              ),
            ),
          );
        }
      }
    } catch (
      e
    ) {
      print(
        'Speech error: $e',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(
              seconds: 2,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(
          () {
            _isListening = false;
          },
        );
      }
      print(
        '=== END LISTENING DEBUG ===',
      );
    }
  }

  @override
  void
  dispose() {
    titleController.dispose();
    _speechService.cancel();
    super.dispose();
  }

  Future<
    void
  >
  _selectDate() async {
    final pickedDate = await showDatePicker(
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
                        ? ColorScheme.dark(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: const Color(
                              0xFF1E1E1E,
                            ),
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
    if (pickedDate !=
        null) {
      setState(
        () {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            selectedDate.hour,
            selectedDate.minute,
          );
        },
      );
    }
  }

  Future<
    void
  >
  _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedDate,
      ),
    );
    if (pickedTime !=
        null) {
      setState(
        () {
          selectedDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        },
      );
    }
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    final categoryController = context
        .watch<
          CategoryController
        >();
    final categories = categoryController.categories
        .map(
          (
            c,
          ) => c.name,
        )
        .toList();

    if (selectedCategory ==
            null &&
        categories.isNotEmpty) {
      selectedCategory =
          categories.contains(
            'Work',
          )
          ? 'Work'
          : categories.first;
    }

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
                widget.task ==
                        null
                    ? 'Add New Task'
                    : 'Edit Task',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge,
              ),
              const SizedBox(
                height: 24,
              ),
              // Title with Voice Input
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Task title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isListening
                          ? Icons.mic
                          : Icons.mic_none,
                      color: _isListening
                          ? AppColors.primary
                          : null,
                    ),
                    onPressed: _startListeningToSpeech,
                    tooltip: 'Say task name',
                  ),
                ),
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
                  DropdownButtonFormField<
                    String
                  >(
                    initialValue: selectedCategory,
                    isExpanded: true,
                    decoration: InputDecoration(
                      isDense: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(
                          left: 12,
                        ),
                        child: Icon(
                          Icons.category,
                          size: 20,
                          color: Colors.transparent,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                        borderSide: const BorderSide(
                          color: AppColors.divider,
                        ),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(
                                context,
                              ).brightness ==
                              Brightness.dark
                          ? const Color(
                              0xFF1E1E1E,
                            )
                          : AppColors.surface,
                    ),
                    alignment: Alignment.center,
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                    dropdownColor:
                        Theme.of(
                              context,
                            ).brightness ==
                            Brightness.dark
                        ? const Color(
                            0xFF1E1E1E,
                          )
                        : AppColors.surface,
                    style: TextStyle(
                      color:
                          Theme.of(
                                context,
                              ).brightness ==
                              Brightness.dark
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontSize: 16,
                    ),
                    elevation: 12,
                    menuMaxHeight: 250,
                    selectedItemBuilder:
                        (
                          BuildContext context,
                        ) {
                          final isDarkMode =
                              Theme.of(
                                context,
                              ).brightness ==
                              Brightness.dark;
                          return categories.map<
                            Widget
                          >(
                            (
                              String category,
                            ) {
                              return Center(
                                child: Text(
                                  category,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          ).toList();
                        },
                    items: categories
                        .map(
                          (
                            category,
                          ) => DropdownMenuItem(
                            value: category,
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      selectedCategory ==
                                          category
                                      ? AppColors.primary.withOpacity(
                                          0.1,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: Text(
                                  category,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        selectedCategory ==
                                            category
                                        ? AppColors.primary
                                        : (Theme.of(
                                                    context,
                                                  ).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : AppColors.textPrimary),
                                    fontSize: 16,
                                    fontWeight:
                                        selectedCategory ==
                                            category
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged:
                        (
                          value,
                        ) {
                          if (value !=
                              null) {
                            setState(
                              () {
                                selectedCategory = value;
                              },
                            );
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
              // Due Date & Time
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time: ${TimeOfDay.fromDateTime(selectedDate).format(context)}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium,
                      ),
                      ElevatedButton(
                        onPressed: _selectTime,
                        child: const Text(
                          'Time',
                        ),
                      ),
                    ],
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
                          if (widget.task ==
                              null) {
                            final newTask = Task(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: titleController.text,
                              dueDate: selectedDate,
                              priority: selectedPriority,
                              isCompleted: false,
                              category:
                                  selectedCategory ??
                                  'Uncategorized',
                            );

                            context
                                .read<
                                  TaskController
                                >()
                                .addTask(
                                  newTask,
                                );
                          } else {
                            final updatedTask = widget.task!.copyWith(
                              title: titleController.text,
                              dueDate: selectedDate,
                              priority: selectedPriority,
                              category:
                                  selectedCategory ??
                                  'Uncategorized',
                            );

                            context
                                .read<
                                  TaskController
                                >()
                                .updateTask(
                                  updatedTask.id,
                                  updatedTask,
                                );
                          }

                          Navigator.pop(
                            context,
                          );

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.task ==
                                        null
                                    ? 'Task added successfully!'
                                    : 'Task updated successfully!',
                              ),
                              duration: const Duration(
                                seconds: 2,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        widget.task ==
                                null
                            ? 'Add Task'
                            : 'Edit',
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
