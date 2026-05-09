import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../controllers/task_controller.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/theme_controller.dart';
import '../views/main_shell.dart';

// Root widget initializing all Provider controllers and app theme
class App
    extends
        StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    // Initialize all state management controllers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryController(), // Category management
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => TaskController(),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => CalendarController(),
        ),
        ChangeNotifierProvider(
          create:
              (
                _,
              ) => ProfileController(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeController(),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Task Manager',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
