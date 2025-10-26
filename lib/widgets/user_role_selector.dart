import 'package:flutter/material.dart';
import '../models/order_models.dart';

class UserRoleSelector extends StatefulWidget {
  const UserRoleSelector({super.key});

  @override
  State<UserRoleSelector> createState() => _UserRoleSelectorState();
}

class _UserRoleSelectorState extends State<UserRoleSelector> {
  UserRole _currentRole = UserRole
      .salesPerson; // Default role since API doesn't provide current role

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin (Full Access)';
      case UserRole.manager:
        return 'Manager (Cost Access)';
      case UserRole.salesPerson:
        return 'Sales Person';
      case UserRole.technician:
        return 'Technician';
      case UserRole.customer:
        return 'Customer';
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.manager:
        return Icons.manage_accounts;
      case UserRole.salesPerson:
        return Icons.person_pin;
      case UserRole.technician:
        return Icons.engineering;
      case UserRole.customer:
        return Icons.person;
    }
  }

  Color _getRoleColor(UserRole role, ColorScheme colorScheme) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.manager:
        return Colors.orange;
      case UserRole.salesPerson:
        return Colors.blue;
      case UserRole.technician:
        return Colors.green;
      case UserRole.customer:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Select User Role'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demo Access Control',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a role to see how different access levels work in the order tracking system.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Available Roles',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                children: UserRole.values.map((role) {
                  final isSelected = role == _currentRole;
                  final roleColor = _getRoleColor(role, colorScheme);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? roleColor.withOpacity(0.1) : null,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getRoleIcon(role), color: roleColor),
                      ),
                      title: Text(
                        _getRoleDisplayName(role),
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? roleColor : null,
                        ),
                      ),
                      subtitle: Text(_getRoleDescription(role)),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: roleColor)
                          : null,
                      onTap: () {
                        setState(() {
                          _currentRole = role;
                        });
                        // TODO: Implement role setting when API supports it
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Role switching feature coming soon'),
                          ),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Role changed to ${_getRoleDisplayName(role)}',
                            ),
                            backgroundColor: roleColor,
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Access Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Access Level',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildAccessItem(
                      'View All Orders',
                      true, // TODO: Implement when API supports permissions
                      theme,
                    ),
                    _buildAccessItem(
                      'Edit Order Stages',
                      false, // TODO: Implement when API supports permissions
                      theme,
                    ),
                    _buildAccessItem(
                      'View Cost Breakdown',
                      true, // TODO: Implement when API supports permissions
                      theme,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Full system access including cost details and editing';
      case UserRole.manager:
        return 'View all orders and cost breakdowns, can edit stages';
      case UserRole.salesPerson:
        return 'View assigned orders, limited editing access';
      case UserRole.technician:
        return 'View technical details, update installation progress';
      case UserRole.customer:
        return 'View own orders only, no editing capabilities';
    }
  }

  Widget _buildAccessItem(String title, bool hasAccess, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            hasAccess ? Icons.check_circle : Icons.cancel,
            color: hasAccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasAccess
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
