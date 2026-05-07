import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/user_stats.dart';
import '../core/services/firebase_auth_service.dart';

// Controller managing user profile state and Firebase authentication
class ProfileController
    extends
        ChangeNotifier {
  // Key for storing profile image in local storage
  static const String
  _imageKey = 'profile_image_path';

  // Firebase authentication service instance
  final FirebaseAuthService
  _authService = FirebaseAuthService();

  // User statistics (completed tasks, total tasks, streak)
  UserStats
  _stats = const UserStats(
    completedCount: 0,
    totalCount: 0,
    streak: 0,
  );

  // Local path to user's profile image
  String?
  _profileImagePath;

  // Error message from authentication
  String?
  _authError;

  // Loading state during auth operations
  bool
  _isLoading = false;

  // Constructor - loads profile on init
  ProfileController() {
    _loadProfile();
  }

  // Getters for profile state
  UserStats
  get stats => _stats;

  String?
  get profileImagePath => _profileImagePath;

  bool
  get isLoggedIn => _authService.isLoggedIn;

  String
  get userName =>
      _authService.currentUser?.email ??
      'Guest User';

  String?
  get authError => _authError;

  bool
  get isLoading => _isLoading;

  // Load profile image from local storage
  Future<
    void
  >
  _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _profileImagePath = prefs.getString(
      _imageKey,
    );
    notifyListeners();
  }

  Future<
    void
  >
  setProfileImage(
    String path,
  ) async {
    _profileImagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _imageKey,
      path,
    );
    notifyListeners();
  }

  Future<
    void
  >
  signUp({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
      );
      _authError = null;
    } catch (
      e
    ) {
      _authError = e.toString().replaceAll(
        'Exception: ',
        '',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<
    void
  >
  login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );
      _authError = null;
    } catch (
      e
    ) {
      _authError = e.toString().replaceAll(
        'Exception: ',
        '',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<
    void
  >
  logout() async {
    try {
      await _authService.signOut();
      _authError = null;
      notifyListeners();
    } catch (
      e
    ) {
      _authError = e.toString();
    }
  }

  Future<
    void
  >
  resetPassword({
    required String email,
  }) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        email: email,
      );
      _authError = null;
    } catch (
      e
    ) {
      _authError = e.toString().replaceAll(
        'Exception: ',
        '',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void
  updateStats(
    List<
      Task
    >
    allTasks,
  ) {
    final completedCount = allTasks
        .where(
          (
            task,
          ) => task.isCompleted,
        )
        .length;
    final totalCount = allTasks.length;

    _stats = UserStats(
      completedCount: completedCount,
      totalCount: totalCount,
      streak: _calculateStreak(
        allTasks,
      ),
    );
    notifyListeners();
  }

  int
  _calculateStreak(
    List<
      Task
    >
    allTasks,
  ) {
    final today = DateTime.now();
    int streak = 0;

    for (
      int i = 0;
      i <
          365;
      i++
    ) {
      final date = today.subtract(
        Duration(
          days: i,
        ),
      );
      final tasksForDay = allTasks.where(
        (
          task,
        ) {
          return task.dueDate.year ==
                  date.year &&
              task.dueDate.month ==
                  date.month &&
              task.dueDate.day ==
                  date.day &&
              task.isCompleted;
        },
      );

      if (tasksForDay.isEmpty) {
        break;
      }
      streak++;
    }

    return streak;
  }

  double
  getCompletionPercentage() {
    if (_stats.totalCount ==
        0)
      return 0;
    return (_stats.completedCount /
            _stats.totalCount) *
        100;
  }
}
