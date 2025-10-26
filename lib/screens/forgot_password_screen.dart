import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.resetPassword(
        email: _emailController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Password reset successful'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to login screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message ?? 'Password reset failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBackToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? colorScheme.surface : const Color(0xFF071428),
            ),
          ),

          // Gradient overlay for light theme
          if (!isDarkMode)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0, 0.4),
                  colors: [
                    colorScheme.secondary.withOpacity(0.8),
                    colorScheme.primary.withOpacity(0.6),
                  ],
                ),
              ),
            ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Back button and header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _handleBackToLogin,
                        icon: Icon(
                          Icons.arrow_back,
                          color: isDarkMode
                              ? colorScheme.onSurface
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reset Password',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDarkMode
                              ? colorScheme.onSurface
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Header section
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.lock_reset,
                            size: 40,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Reset Your Password',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDarkMode
                                ? colorScheme.onSurface
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Enter your email and new password to reset your account password',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode
                                  ? colorScheme.onSurface.withOpacity(0.7)
                                  : Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form section
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Card(
                          elevation: 0,
                          color: Colors.transparent,
                          shadowColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Email field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email Address',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? colorScheme.onSurface
                                                  : Colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _emailController,
                                        validator: _validateEmail,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? colorScheme.onSurface
                                              : Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your email address',
                                          hintStyle: TextStyle(
                                            color: isDarkMode
                                                ? colorScheme.onSurface
                                                      .withOpacity(0.5)
                                                : Colors.white.withOpacity(0.5),
                                          ),
                                          filled: true,
                                          fillColor: isDarkMode
                                              ? Colors.white.withOpacity(0.02)
                                              : const Color(0xFF0f2a35),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 16,
                                              ),
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                            color: isDarkMode
                                                ? colorScheme.onSurface
                                                      .withOpacity(0.7)
                                                : Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // New Password field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'New Password',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? colorScheme.onSurface
                                                  : Colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _newPasswordController,
                                        validator: _validatePassword,
                                        obscureText: !_showNewPassword,
                                        textInputAction: TextInputAction.next,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? colorScheme.onSurface
                                              : Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Enter new password',
                                          hintStyle: TextStyle(
                                            color: isDarkMode
                                                ? colorScheme.onSurface
                                                      .withOpacity(0.5)
                                                : Colors.white.withOpacity(0.5),
                                          ),
                                          filled: true,
                                          fillColor: isDarkMode
                                              ? Colors.white.withOpacity(0.02)
                                              : const Color(0xFF0f2a35),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 16,
                                              ),
                                          prefixIcon: Icon(
                                            Icons.lock_outlined,
                                            color: isDarkMode
                                                ? colorScheme.onSurface
                                                      .withOpacity(0.7)
                                                : Colors.white.withOpacity(0.7),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _showNewPassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: isDarkMode
                                                  ? colorScheme.onSurface
                                                        .withOpacity(0.7)
                                                  : Colors.white.withOpacity(
                                                      0.7,
                                                    ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _showNewPassword =
                                                    !_showNewPassword;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Confirm Password field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Confirm New Password',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: isDarkMode
                                                  ? colorScheme.onSurface
                                                  : Colors.white,
                                            ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        validator: _validateConfirmPassword,
                                        obscureText: !_showConfirmPassword,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) =>
                                            _handleResetPassword(),
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? colorScheme.onSurface
                                              : Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Confirm new password',
                                          hintStyle: TextStyle(
                                            color: isDarkMode
                                                ? colorScheme.onSurface
                                                      .withOpacity(0.5)
                                                : Colors.white.withOpacity(0.5),
                                          ),
                                          filled: true,
                                          fillColor: isDarkMode
                                              ? Colors.white.withOpacity(0.02)
                                              : const Color(0xFF0f2a35),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 16,
                                              ),
                                          prefixIcon: Icon(
                                            Icons.lock_outlined,
                                            color: isDarkMode
                                                ? colorScheme.onSurface
                                                      .withOpacity(0.7)
                                                : Colors.white.withOpacity(0.7),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _showConfirmPassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: isDarkMode
                                                  ? colorScheme.onSurface
                                                        .withOpacity(0.7)
                                                  : Colors.white.withOpacity(
                                                      0.7,
                                                    ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _showConfirmPassword =
                                                    !_showConfirmPassword;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),

                                  // Reset password button
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _handleResetPassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.secondary,
                                        foregroundColor:
                                            colorScheme.onSecondary,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(colorScheme.onSecondary),
                                              ),
                                            )
                                          : Text(
                                              'RESET PASSWORD',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: colorScheme.onSecondary,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Back to login link
                                  Center(
                                    child: TextButton(
                                      onPressed: _handleBackToLogin,
                                      child: RichText(
                                        text: TextSpan(
                                          text: "Remember your password? ",
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: isDarkMode
                                                    ? colorScheme.onSurface
                                                          .withOpacity(0.7)
                                                    : Colors.white.withOpacity(
                                                        0.7,
                                                      ),
                                              ),
                                          children: [
                                            TextSpan(
                                              text: 'Sign in',
                                              style: TextStyle(
                                                color: colorScheme.secondary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
