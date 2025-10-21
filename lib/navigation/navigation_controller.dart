import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/home_screen.dart';
import '../screens/leads_screen.dart';
import '../screens/add_lead_screen.dart';
import '../screens/directory_screen.dart';
import '../screens/follow_ups_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/emi_calculator_screen.dart';
import '../widgets/main_drawer.dart';
import '../services/auth_service.dart';

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  String _currentRoute = 'dashboard';
  late Widget _currentScreen;
  late Map<String, Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
    _currentScreen = _screens['dashboard']!;
  }

  void _initializeScreens() {
    _screens = {
      'dashboard': const DashboardScreen(),
      'leads': const LeadsScreen(),
      'add_lead': const AddLeadScreen(),
      'directory': const DirectoryScreen(),
      'follow_ups': const FollowUpsScreen(),
      'orders': const OrdersScreen(),
      'emi_calculator': const EMICalculatorScreen(),
      'customer_lookup': const HomeScreen(),
      'settings': const DashboardScreen(),
      // Legacy routes for backward compatibility
      'analytics': const _ComingSoonScreen(title: 'Analytics'),
      'solar_calculator': const _ComingSoonScreen(title: 'Solar Calculator'),
      'payments': const _ComingSoonScreen(title: 'Payments'),
      'inventory': const _ComingSoonScreen(title: 'Inventory'),
      'installations': const _ComingSoonScreen(title: 'Installations'),
      'maintenance': const _ComingSoonScreen(title: 'Maintenance'),
      'service_requests': const _ComingSoonScreen(title: 'Service Requests'),
      'sales_reports': const _ComingSoonScreen(title: 'Sales Reports'),
      'performance': const _ComingSoonScreen(title: 'Performance'),
      'help': const _ComingSoonScreen(title: 'Help & Support'),
    };
  }

  void _navigateToRoute(String route, {bool fromDrawer = true}) {
    if (route == 'logout') {
      _handleLogout();
      return;
    }

    // Check if the screen is available
    if (_screens.containsKey(route)) {
      setState(() {
        _currentRoute = route;
        _currentScreen = _screens[route]!;
      });
      if (fromDrawer) {
        Navigator.of(
          context,
        ).pop(); // Close drawer only if navigation is from drawer
      }
    } else {
      // Handle unavailable routes with a snackbar
      if (fromDrawer) {
        Navigator.of(context).pop(); // Close drawer first if from drawer
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getAppBarTitle(route)} is not available yet'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Clear auth state
              await AuthService.logout();

              // Navigate to login screen
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle([String? route]) {
    final targetRoute = route ?? _currentRoute;
    switch (targetRoute) {
      case 'dashboard':
        return 'Dashboard';
      case 'leads':
        return 'Leads';
      case 'add_lead':
        return 'Add Lead';
      case 'directory':
        return 'Directory';
      case 'follow_ups':
        return 'Follow-ups';
      case 'orders':
        return 'Orders';
      case 'emi_calculator':
        return 'EMI Calculator';
      case 'customer_lookup':
        return 'Bill Lookup';
      case 'settings':
        return 'Settings';
      // Legacy routes
      case 'analytics':
        return 'Analytics';
      case 'solar_calculator':
        return 'Solar Calculator';
      case 'payments':
        return 'Payments';
      case 'inventory':
        return 'Inventory';
      case 'installations':
        return 'Installations';
      case 'maintenance':
        return 'Maintenance';
      case 'service_requests':
        return 'Service Requests';
      case 'sales_reports':
        return 'Sales Reports';
      case 'performance':
        return 'Performance';
      case 'help':
        return 'Help & Support';
      default:
        return 'Solar Phoenix';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        // If not on dashboard, navigate to dashboard instead of closing app
        if (_currentRoute != 'dashboard') {
          setState(() {
            _currentRoute = 'dashboard';
            _currentScreen = _screens['dashboard']!;
          });
        } else {
          // If on dashboard, show exit confirmation
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );

          if (shouldExit == true) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getAppBarTitle()),
          centerTitle: false,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          actions: [
            // Notifications
            IconButton(
              onPressed: () {
                // Handle notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: 'Notifications',
            ),

            // Profile menu
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    _navigateToRoute('settings', fromDrawer: false);
                    break;
                  case 'logout':
                    _handleLogout();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              child: const CircleAvatar(
                radius: 16,
                child: Icon(Icons.person, size: 18),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        drawer: MainDrawer(
          onItemTap: _navigateToRoute,
          currentRoute: _currentRoute,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _currentScreen,
        ),

        // Floating Action Button for quick actions
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentRoute) {
      case 'dashboard':
        return FloatingActionButton(
          heroTag: "dashboard_fab",
          onPressed: () => _navigateToRoute('add_lead', fromDrawer: false),
          tooltip: 'Add Lead',
          child: const Icon(Icons.add),
        );
      case 'leads':
        return FloatingActionButton(
          heroTag: "leads_fab",
          onPressed: () => _navigateToRoute('add_lead', fromDrawer: false),
          tooltip: 'Add Lead',
          child: const Icon(Icons.person_add),
        );
      case 'directory':
        return FloatingActionButton(
          heroTag: "directory_fab",
          onPressed: () => _navigateToRoute('add_lead', fromDrawer: false),
          tooltip: 'Add Contact',
          child: const Icon(Icons.add),
        );
      case 'orders':
        return FloatingActionButton(
          heroTag: "orders_fab",
          onPressed: () {
            // Handle add order - could navigate to a form or show dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add Order feature coming soon')),
            );
          },
          tooltip: 'Add Order',
          child: const Icon(Icons.add_shopping_cart),
        );
      case 'follow_ups':
        return FloatingActionButton(
          heroTag: "follow_ups_fab",
          onPressed: () {
            // Handle add follow-up
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add Follow-up feature coming soon'),
              ),
            );
          },
          tooltip: 'Add Follow-up',
          child: const Icon(Icons.add_task),
        );
      default:
        return null;
    }
  }
}

class _ComingSoonScreen extends StatelessWidget {
  final String title;

  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Coming Soon!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
