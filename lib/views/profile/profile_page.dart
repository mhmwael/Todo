import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                onTap: () {
                  // Simulate image picking
                  profileController.setProfileImage('assets/images/logo.png');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile picture updated')),
                  );
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: profileController.profileImageFile != null
                      ? FileImage(profileController.profileImageFile!) as ImageProvider
                      : (profileController.profileImagePath != null
                          ? AssetImage(profileController.profileImagePath!)
                          : null),
                  child: profileController.profileImageFile == null &&
                          profileController.profileImagePath == null
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
                      profileController.isLoggedIn ? 'Sign Out' : 'Sign In',
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
