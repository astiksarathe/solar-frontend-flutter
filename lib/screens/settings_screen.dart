import 'package:flutter/material.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = ThemeProvider.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customize your app experience',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Section
            _buildSettingsSection(context, 'Account', Icons.person, [
              _buildSettingsTile(
                'Profile Information',
                'Update your personal details',
                Icons.edit,
                () => _showComingSoon(context, 'Profile editing'),
              ),
              _buildSettingsTile(
                'Change Password',
                'Update your account password',
                Icons.lock,
                () => _showComingSoon(context, 'Password change'),
              ),
              _buildSettingsTile(
                'Two-Factor Authentication',
                'Add extra security to your account',
                Icons.security,
                () => _showComingSoon(context, 'Two-factor authentication'),
              ),
            ]),

            const SizedBox(height: 24),

            // Appearance Section
            _buildSettingsSection(context, 'Appearance', Icons.palette, [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark theme'),
                trailing: Switch(
                  value: theme.brightness == Brightness.dark,
                  onChanged: (value) {
                    themeProvider?.toggleTheme();
                  },
                ),
              ),
              _buildDropdownTile(
                'Language',
                'Choose your preferred language',
                Icons.language,
                _selectedLanguage,
                ['English', 'Hindi', 'Marathi', 'Gujarati'],
                (value) => setState(() => _selectedLanguage = value!),
              ),
              _buildDropdownTile(
                'Currency',
                'Select currency for calculations',
                Icons.currency_rupee,
                _selectedCurrency,
                ['INR (₹)', 'USD (\$)', 'EUR (€)'],
                (value) => setState(() => _selectedCurrency = value!),
              ),
            ]),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSettingsSection(
              context,
              'Notifications',
              Icons.notifications,
              [
                ListTile(
                  leading: const Icon(Icons.notifications_active),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive app notifications'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) =>
                        setState(() => _notificationsEnabled = value),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive updates via email'),
                  trailing: Switch(
                    value: _emailNotifications,
                    onChanged: (value) =>
                        setState(() => _emailNotifications = value),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sms),
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Receive SMS updates'),
                  trailing: Switch(
                    value: _smsNotifications,
                    onChanged: (value) =>
                        setState(() => _smsNotifications = value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data & Privacy Section
            _buildSettingsSection(
              context,
              'Data & Privacy',
              Icons.privacy_tip,
              [
                _buildSettingsTile(
                  'Data Export',
                  'Download your data',
                  Icons.download,
                  () => _showComingSoon(context, 'Data export'),
                ),
                _buildSettingsTile(
                  'Privacy Policy',
                  'Read our privacy policy',
                  Icons.policy,
                  () => _showComingSoon(context, 'Privacy policy'),
                ),
                _buildSettingsTile(
                  'Terms of Service',
                  'View terms and conditions',
                  Icons.description,
                  () => _showComingSoon(context, 'Terms of service'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Support Section
            _buildSettingsSection(context, 'Support', Icons.help, [
              _buildSettingsTile(
                'Help Center',
                'Get help and support',
                Icons.help_center,
                () => _showComingSoon(context, 'Help center'),
              ),
              _buildSettingsTile(
                'Contact Support',
                'Get in touch with our team',
                Icons.contact_support,
                () => _showComingSoon(context, 'Contact support'),
              ),
              _buildSettingsTile(
                'Report Bug',
                'Report an issue or bug',
                Icons.bug_report,
                () => _showComingSoon(context, 'Bug reporting'),
              ),
              _buildSettingsTile(
                'About',
                'App version and information',
                Icons.info,
                () => _showAboutDialog(context),
              ),
            ]),

            const SizedBox(height: 24),

            // Danger Zone
            Card(
              color: colorScheme.errorContainer.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Text(
                          'Danger Zone',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showComingSoon(context, 'Account deletion'),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Delete Account'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Solar Phoenix',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.solar_power,
          color: Theme.of(context).colorScheme.primary,
          size: 32,
        ),
      ),
      children: [
        const Text('A comprehensive solar business management app.'),
        const SizedBox(height: 16),
        const Text('Built with Flutter and ❤️'),
      ],
    );
  }
}
