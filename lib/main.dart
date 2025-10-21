import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/emi_calculator_screen.dart';
import 'screens/leads_screen.dart';
import 'screens/directory_screen.dart';
import 'screens/follow_ups_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/login_screen.dart';
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
    return MaterialApp(
      title: 'Solar Phoenix',
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: ThemeProvider(
        isDarkMode: _isDarkMode,
        toggleTheme: _toggleTheme,
        child: const LoginScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      child: const MainNavigationScreen(),
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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EMICalculatorScreen(),
    const LeadsScreen(),
    const DirectoryScreen(),
    const FollowUpsScreen(),
    const OrdersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'EMI Calculator',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Leads'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Directory'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Follow-ups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
