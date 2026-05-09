import 'package:flutter/foundation.dart';
import '../models/task.dart';

// Controller managing calendar view and date selection
class CalendarController
    extends
        ChangeNotifier {
  late DateTime
  _selectedDate; // Currently selected date in calendar

  CalendarController() {
    _selectedDate = DateTime.now(); // Initialize to today
  }

  DateTime
  get selectedDate => _selectedDate; // Get selected date

  // Update selected date and notify listeners
  void
  setSelectedDate(
    DateTime date,
  ) {
    _selectedDate = date;
    notifyListeners();
  }

  // Get all tasks for a specific day
  List<
    Task
  >
  getTasksForDay(
    List<
      Task
    >
    allTasks,
    DateTime date,
  ) {
    return allTasks.where(
      (
        task,
      ) {
        return task.dueDate.year ==
                date.year &&
            task.dueDate.month ==
                date.month &&
            task.dueDate.day ==
                date.day;
      },
    ).toList();
  }

  bool
  hasTasksForDay(
    List<
      Task
    >
    allTasks,
    DateTime date,
  ) {
    return getTasksForDay(
      allTasks,
      date,
    ).isNotEmpty;
  }
}
