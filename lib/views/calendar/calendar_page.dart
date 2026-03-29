import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
        ),
        backgroundColor: Theme.of(
          context,
        ).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(
          context,
        ).textTheme.displayLarge?.color,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(
            32.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: 64,
                color: AppColors.primary.withOpacity(
                  0.3,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'Calendar view coming soon',
                style:
                    Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
