import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/profile_controller.dart';
import '../../core/theme/app_colors.dart';

class AuthDialog
    extends
        StatefulWidget {
  final bool
  isSignUp;

  const AuthDialog({
    super.key,
    this.isSignUp = false,
  });

  @override
  State<
    AuthDialog
  >
  createState() => _AuthDialogState();
}

class _AuthDialogState
    extends
        State<
          AuthDialog
        > {
  late bool
  _isSignUp;
  late TextEditingController
  _emailController;
  late TextEditingController
  _passwordController;
  late TextEditingController
  _confirmPasswordController;
  bool
  _obscurePassword = true;
  bool
  _obscureConfirmPassword = true;

  @override
  void
  initState() {
    super.initState();
    _isSignUp = widget.isSignUp;
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void
  dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Consumer<
      ProfileController
    >(
      builder:
          (
            context,
            profileController,
            _,
          ) {
            return AlertDialog(
              title: Text(
                _isSignUp
                    ? 'Sign Up'
                    : 'Sign In',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Email Field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(
                          Icons.email,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(
                              () {
                                _obscurePassword = !_obscurePassword;
                              },
                            );
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    // Confirm Password Field (for Sign Up)
                    if (_isSignUp)
                      Column(
                        children: [
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              prefixIcon: const Icon(
                                Icons.lock,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(
                                    () {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    },
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                        ],
                      ),
                    // Error Message
                    if (profileController.authError !=
                        null)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(
                            12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              8,
                            ),
                            border: Border.all(
                              color: Colors.red,
                            ),
                          ),
                          child: Text(
                            profileController.authError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    // Toggle Sign Up / Sign In
                    GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            _isSignUp = !_isSignUp;
                            _emailController.clear();
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                          },
                        );
                      },
                      child: Text(
                        _isSignUp
                            ? 'Already have an account? Sign In'
                            : 'Don\'t have an account? Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
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
                  onPressed: profileController.isLoading
                      ? null
                      : () async {
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please fill in all fields',
                                ),
                              ),
                            );
                            return;
                          }

                          if (_isSignUp) {
                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Passwords do not match',
                                  ),
                                ),
                              );
                              return;
                            }

                            await profileController.signUp(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          } else {
                            await profileController.login(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          }

                          if (mounted) {
                            if (profileController.authError ==
                                    null &&
                                profileController.isLoggedIn) {
                              Navigator.pop(
                                context,
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isSignUp
                                        ? 'Account created successfully!'
                                        : 'Signed in successfully!',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  child: profileController.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isSignUp
                              ? 'Sign Up'
                              : 'Sign In',
                        ),
                ),
              ],
            );
          },
    );
  }
}
