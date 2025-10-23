import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
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
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
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
    if (value != _passwordController.text) {
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
                // Header section
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo image placeholder
                        Container(
                          width: 64,
                          height: 64,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.wb_sunny,
                            size: 36,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'Create Account',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDarkMode
                                ? colorScheme.onSurface
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Join Solar-Stack today',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode
                                ? colorScheme.onSurface.withOpacity(0.7)
                                : Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form section
                Expanded(
                  flex: 4,
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
                                          hintText: 'Enter your email',
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
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Password field
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Password',
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
                                        controller: _passwordController,
                                        validator: _validatePassword,
                                        obscureText: !_showPassword,
                                        textInputAction: TextInputAction.next,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? colorScheme.onSurface
                                              : Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Create a password',
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
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _showPassword
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
                                                _showPassword = !_showPassword;
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
                                        'Confirm Password',
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
                                            _handleSignUp(),
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? colorScheme.onSurface
                                              : Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Confirm your password',
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
                                  const SizedBox(height: 16),

                                  // Terms and conditions checkbox
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) {
                                          setState(() {
                                            _agreeToTerms = value ?? false;
                                          });
                                        },
                                        activeColor: colorScheme.secondary,
                                        checkColor: colorScheme.onSecondary,
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 12,
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              text: 'I agree to the ',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: isDarkMode
                                                        ? colorScheme.onSurface
                                                              .withOpacity(0.7)
                                                        : Colors.white
                                                              .withOpacity(0.7),
                                                  ),
                                              children: [
                                                TextSpan(
                                                  text: 'Terms and Conditions',
                                                  style: TextStyle(
                                                    color:
                                                        colorScheme.secondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const TextSpan(text: ' and '),
                                                TextSpan(
                                                  text: 'Privacy Policy',
                                                  style: TextStyle(
                                                    color:
                                                        colorScheme.secondary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Sign up button
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _handleSignUp,
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
                                              'CREATE ACCOUNT',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: colorScheme.onSecondary,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 22),

                                  // Divider
                                  Container(
                                    height: 1,
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.04)
                                        : Colors.white.withOpacity(0.06),
                                  ),
                                  const SizedBox(height: 22),

                                  // Sign in link
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Already have an account? ",
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
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: _handleBackToLogin,
                                              child: Text(
                                                'Sign in',
                                                style: TextStyle(
                                                  color: colorScheme.secondary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
