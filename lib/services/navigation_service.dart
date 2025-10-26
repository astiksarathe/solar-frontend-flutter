import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Navigate to login screen and clear all previous routes
  static Future<void> navigateToLogin() async {
    if (navigator != null) {
      await navigator!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Get current context
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Show snackbar with message
  static void showSnackBar(String message, {bool isError = false}) {
    final context = currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : null,
        ),
      );
    }
  }
}
