import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/theme_controller.dart';
import '../auth/auth_dialog.dart';

// User profile page with profile picture, statistics, authentication, and theme settings
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
    // Listen to profile and theme controller changes
    return Consumer2<
      ProfileController,
      ThemeController
    >(
      builder:
          (
            context,
            profileController,
            themeController,
            _,
          ) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(
                          context,
                        ).padding.top +
                        16,
                  ),
                  Text(
                    'Profile',
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  // Circular Profile Pic
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );

                      if (image !=
                          null) {
                        profileController.setProfileImage(
                          image.path,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profile picture updated',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary.withOpacity(
                        0.1,
                      ),
                      backgroundImage:
                          profileController.profileImagePath !=
                              null
                          ? FileImage(
                                  File(
                                    profileController.profileImagePath!,
                                  ),
                                )
                                as ImageProvider
                          : null,
                      child:
                          profileController.profileImagePath ==
                              null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    profileController.userName,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  // Dark Mode Toggle
                  SwitchListTile(
                    title: const Text(
                      'Dark Mode',
                    ),
                    secondary: Icon(
                      themeController.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                    value: themeController.isDarkMode,
                    onChanged:
                        (
                          value,
                        ) => themeController.toggleTheme(),
                  ),
                  const Divider(),
                  // Login/Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (profileController.isLoggedIn) {
                            // Show logout confirmation
                            showDialog(
                              context: context,
                              builder:
                                  (
                                    context,
                                  ) => AlertDialog(
                                    title: const Text(
                                      'Sign Out?',
                                    ),
                                    content: const Text(
                                      'Are you sure you want to sign out? Your tasks will remain synced to your account.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                        ),
                                        child: const Text(
                                          'Cancel',
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          profileController.logout();
                                          Navigator.pop(
                                            context,
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Signed out successfully',
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.highPriority,
                                        ),
                                        child: const Text(
                                          'Sign Out',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          } else {
                            // Show login/signup dialog
                            showDialog(
                              context: context,
                              builder:
                                  (
                                    context,
                                  ) => const AuthDialog(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: profileController.isLoggedIn
                              ? AppColors.highPriority
                              : AppColors.primary,
                        ),
                        child: Text(
                          profileController.isLoggedIn
                              ? 'Sign Out'
                              : 'Sign in / Sign Up',
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
    );
  }
}
