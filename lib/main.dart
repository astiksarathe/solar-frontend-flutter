import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'navigation/navigation_controller.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SolarPhoenixApp());
}

class SolarPhoenixApp extends StatefulWidget {
  const SolarPhoenixApp({super.key});

  @override
  State<SolarPhoenixApp> createState() => _SolarPhoenixAppState();
}

class _SolarPhoenixAppState extends State<SolarPhoenixApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      isDarkMode: _isDarkMode,
      toggleTheme: _toggleTheme,
      child: MaterialApp(
        title: 'Solar Phoenix',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/main': (context) => const NavigationController(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class ThemeProvider extends InheritedWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const ThemeProvider({
    super.key,
    required this.isDarkMode,
    required this.toggleTheme,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return isDarkMode != oldWidget.isDarkMode;
  }
}
