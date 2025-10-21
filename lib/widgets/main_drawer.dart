import 'package:flutter/material.dart';
import '../main.dart';

class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final String route;

  const MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.route,
  });
}

class MainDrawer extends StatelessWidget {
  final Function(String) onItemTap;
  final String currentRoute;

  const MainDrawer({
    super.key,
    required this.onItemTap,
    required this.currentRoute,
  });

  static const List<MenuItem> menuItems = [
    MenuItem(
      id: 'dashboard',
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: 'dashboard',
    ),
    MenuItem(
      id: 'leads',
      title: 'Leads',
      icon: Icons.people_outline,
      route: 'leads',
    ),
    MenuItem(
      id: 'addLead',
      title: 'Add Lead',
      icon: Icons.person_add,
      route: 'add_lead',
    ),
    MenuItem(
      id: 'directory',
      title: 'Directory',
      icon: Icons.folder_open,
      route: 'directory',
    ),
    MenuItem(
      id: 'followups',
      title: 'Follow-ups',
      icon: Icons.schedule,
      route: 'follow_ups',
    ),
    MenuItem(
      id: 'orders',
      title: 'Orders',
      icon: Icons.shopping_cart_outlined,
      route: 'orders',
    ),
    MenuItem(
      id: 'emiCalculator',
      title: 'EMI Calculator',
      icon: Icons.calculate,
      route: 'emi_calculator',
    ),
    MenuItem(
      id: 'billAnalysis',
      title: 'Bill Analysis',
      icon: Icons.receipt_long,
      route: 'bill_analysis',
    ),
    MenuItem(
      id: 'settings',
      title: 'Settings',
      icon: Icons.settings,
      route: 'settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final themeProvider = ThemeProvider.of(context);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0, 0.4),
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.surface,
                  ],
                ),
          color: isDarkMode ? theme.colorScheme.surface : null,
        ),

        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Header Section
                    _buildHeader(context, isDarkMode),

                    // Profile Section
                    _buildProfileSection(context, theme),

                    // Divider
                    _buildDivider(context, theme),

                    // Menu Items
                    _buildMenuCard(context, theme),

                    // Bottom Divider
                    _buildDivider(context, theme),
                  ],
                ),
              ),
            ),

            // Bottom Section
            _buildBottomSection(context, theme, themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🌞', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Solar Phoenix',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.person,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, User 👋',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'View Profile',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context, ThemeData theme) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: theme.colorScheme.outline.withOpacity(0.2),
    );
  }

  Widget _buildMenuCard(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == menuItems.length - 1;

          return _buildMenuItem(context, theme, item, !isLast);
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ThemeData theme,
    MenuItem item,
    bool showDivider,
  ) {
    final isSelected = currentRoute == item.route;

    return InkWell(
      onTap: () => onItemTap(item.route),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    ThemeData theme,
    ThemeProvider? themeProvider,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Feature Coming Soon Card
            _buildBottomCard(
              context,
              theme,
              icon: Icons.lightbulb_outline,
              title: 'Feature coming soon',
              trailing: Icon(
                Icons.info_outline,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
              onTap: () {},
            ),

            const SizedBox(height: 8),

            // Dark Mode Toggle Card
            _buildBottomCard(
              context,
              theme,
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: theme.brightness == Brightness.dark,
                onChanged: (value) {
                  themeProvider?.toggleTheme();
                },
                activeThumbColor: theme.colorScheme.primary,
              ),
              onTap: () {
                themeProvider?.toggleTheme();
              },
            ),

            const SizedBox(height: 8),

            // Logout Card
            _buildBottomCard(
              context,
              theme,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () => onItemTap('logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
