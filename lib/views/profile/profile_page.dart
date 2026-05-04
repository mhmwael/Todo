import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/theme_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileController, ThemeController>(
      builder: (context, profileController, themeController, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 16),
              Text(
                'Profile',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 32),
              // Circular Profile Pic
              GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (image != null) {
                    profileController.setProfileImage(image.path);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture updated'),
                        ),
                      );
                    }
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: profileController.profileImagePath != null
                      ? FileImage(File(profileController.profileImagePath!))
                          as ImageProvider
                      : null,
                  child: profileController.profileImagePath == null
                      ? Icon(Icons.person, size: 60, color: AppColors.primary)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profileController.userName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              // Dark Mode Toggle
              SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: Icon(
                  themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primary,
                ),
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.toggleTheme(),
              ),
              const Divider(),
              // Login/Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (profileController.isLoggedIn) {
                        profileController.logout();
                      } else {
                        profileController.login();
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
                          : 'Sign in / Login',
                      style: const TextStyle(color: Colors.white),
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
