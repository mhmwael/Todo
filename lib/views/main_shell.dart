import 'package:flutter/material.dart';
import '../core/theme/app_strings.dart';
import 'tasks/tasks_page.dart';
import 'calendar/calendar_page.dart';
import 'profile/profile_page.dart';

class MainShell
    extends
        StatefulWidget {
  const MainShell({
    super.key,
  });

  @override
  State<
    MainShell
  >
  createState() => _MainShellState();
}

class _MainShellState
    extends
        State<
          MainShell
        > {
  int
  _selectedIndex = 0;

  static const List<
    Widget
  >
  _pages =
      <
        Widget
      >[
        TasksPage(),
        CalendarPage(),
        ProfilePage(),
      ];

  void
  _onItemTapped(
    int index,
  ) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items:
            const <
              BottomNavigationBarItem
            >[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.check_circle_outline,
                ),
                activeIcon: Icon(
                  Icons.check_circle,
                ),
                label: AppStrings.tasks,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.calendar_today,
                ),
                activeIcon: Icon(
                  Icons.calendar_today,
                ),
                label: AppStrings.calendar,
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline,
                ),
                activeIcon: Icon(
                  Icons.person,
                ),
                label: AppStrings.profile,
              ),
            ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
