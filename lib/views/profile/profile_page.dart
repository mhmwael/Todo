import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProfilePage
    extends
        StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top padding for notification bar
        SizedBox(
          height:
              MediaQuery.of(
                context,
              ).padding.top +
              8,
        ),
        Padding(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: Text(
            'Profile',
            style: Theme.of(
              context,
            ).textTheme.displayLarge,
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(
              32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person,
                  size: 64,
                  color: AppColors.primary.withOpacity(
                    0.3,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Profile page coming soon',
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
      ],
    );
  }
}
