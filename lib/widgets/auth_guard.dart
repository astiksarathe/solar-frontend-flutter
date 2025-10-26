import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

/// A widget that protects child widgets by checking authentication status
/// Automatically redirects to login if user is not authenticated
class AuthGuard extends StatefulWidget {
  final Widget child;
  final Widget? loadingWidget;

  const AuthGuard({super.key, required this.child, this.loadingWidget});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool? _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isAuthenticated = isLoggedIn;
      });

      // If not authenticated, redirect to login
      if (!isLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated == null) {
      // Show loading while checking authentication
      return widget.loadingWidget ??
          const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isAuthenticated == true) {
      return widget.child;
    }

    // If not authenticated, show empty container while redirecting
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// A mixin that provides authentication checking functionality to StatefulWidgets
mixin AuthStateMixin<T extends StatefulWidget> on State<T> {
  Future<bool> checkAuthenticationStatus() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      // Redirect to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
      return false;
    }
    return isLoggedIn;
  }
}
