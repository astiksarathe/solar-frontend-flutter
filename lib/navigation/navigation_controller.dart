import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/emi_calculator_screen.dart';
import '../screens/leads_screen.dart';
import '../screens/add_lead_screen.dart';
import '../screens/directory_screen.dart';
import '../screens/follow_ups_screen.dart';
import '../screens/orders_screen.dart';
import '../widgets/main_drawer.dart';

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  String _currentRoute = 'dashboard';
  Widget _currentScreen = const DashboardScreen();

  final Map<String, Widget> _screens = {
    'dashboard': const DashboardScreen(),
    'leads': const LeadsScreen(),
    'add_lead': const AddLeadScreen(),
    'directory': const DirectoryScreen(),
    'follow_ups': const FollowUpsScreen(),
    'orders': const OrdersScreen(),
    'emi_calculator': const EMICalculatorScreen(),
    'bill_analysis': const _ComingSoonScreen(title: 'Bill Analysis'),
    'settings': const _ComingSoonScreen(title: 'Settings'),
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

  void _navigateToRoute(String route) {
    if (route == 'logout') {
      _handleLogout();
      return;
    }

    if (_screens.containsKey(route)) {
      setState(() {
        _currentRoute = route;
        _currentScreen = _screens[route]!;
      });
      Navigator.of(context).pop(); // Close drawer
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
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentRoute) {
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
      case 'bill_analysis':
        return 'Bill Analysis';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        actions: [
          // Quick action buttons for frequent tasks
          if (_currentRoute == 'dashboard') ...[
            IconButton(
              onPressed: () => _navigateToRoute('add_lead'),
              icon: const Icon(Icons.person_add),
              tooltip: 'Add Lead',
            ),
            IconButton(
              onPressed: () => _navigateToRoute('emi_calculator'),
              icon: const Icon(Icons.calculate),
              tooltip: 'EMI Calculator',
            ),
          ],

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
                  _navigateToRoute('settings');
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
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentRoute) {
      case 'dashboard':
        return FloatingActionButton(
          onPressed: () => _navigateToRoute('add_lead'),
          tooltip: 'Add Lead',
          child: const Icon(Icons.add),
        );
      case 'leads':
        return FloatingActionButton(
          onPressed: () => _navigateToRoute('add_lead'),
          tooltip: 'Add Lead',
          child: const Icon(Icons.person_add),
        );
      case 'directory':
        return FloatingActionButton(
          onPressed: () => _navigateToRoute('add_lead'),
          tooltip: 'Add Contact',
          child: const Icon(Icons.add),
        );
      case 'orders':
        return FloatingActionButton(
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
