import 'package:flutter/foundation.dart';
import '../models/task.dart';

class CalendarController extends ChangeNotifier {
  late DateTime _selectedDate;

  CalendarController() {
    _selectedDate = DateTime.now();
  }

  DateTime get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Task> getTasksForDay(List<Task> allTasks, DateTime date) {
    return allTasks.where((task) {
      return task.dueDate.year == date.year &&
          task.dueDate.month == date.month &&
          task.dueDate.day == date.day;
    }).toList();
  }

  bool hasTasksForDay(List<Task> allTasks, DateTime date) {
    return getTasksForDay(allTasks, date).isNotEmpty;
  }
}
