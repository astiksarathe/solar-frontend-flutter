import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../navigation/navigation_controller.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate login delay
      await Future.delayed(const Duration(seconds: 2));

      // Save login state
      await AuthService.login(_emailController.text.trim());

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NavigationController()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSignUp() {
    // Add sign up navigation logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign up functionality coming soon!')),
    );
  }

  void _handleForgotPassword() {
    // Add forgot password logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Forgot password functionality coming soon!'),
      ),
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
                // Logo section
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo image placeholder
                        Container(
                          width: 84,
                          height: 84,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
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
                            size: 48,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          'Solar-Stack',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDarkMode
                                ? colorScheme.onSurface
                                : Colors.white,
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
                                          hintText: 'Email address',
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
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _handleLogin(),
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? colorScheme.onSurface
                                              : Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Password',
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
                                  const SizedBox(height: 12),

                                  // Forgot password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _handleForgotPassword,
                                      child: Text(
                                        'Forgot Password?',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: isDarkMode
                                                  ? colorScheme.onSurface
                                                        .withOpacity(0.7)
                                                  : Colors.white.withOpacity(
                                                      0.7,
                                                    ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Login button
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _handleLogin,
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
                                              'LOGIN',
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

                                  // Sign up link
                                  Center(
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Don't have an account? ",
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
                                              onTap: _handleSignUp,
                                              child: Text(
                                                'Sign up',
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
