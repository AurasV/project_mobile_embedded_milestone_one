import 'package:flutter/material.dart';
import 'app_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive medication reminders',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeTrackColor: theme.colorScheme.primary,
              ),
            ),
            _buildSettingItem(
              icon: Icons.volume_up,
              title: 'Sound',
              subtitle: 'Play sound for reminders',
              trailing: Switch(
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                },
                activeTrackColor: theme.colorScheme.primary,
              ),
            ),
            _buildSettingItem(
              icon: Icons.vibration,
              title: 'Vibration',
              subtitle: 'Vibrate for reminders',
              trailing: Switch(
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                },
                activeTrackColor: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Light Mode',
              trailing: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // Theme picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme picker coming soon!')),
                  );
                },
              ),
            ),
            _buildSettingItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'English',
              trailing: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  // Language picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Language picker coming soon!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Data & Privacy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              icon: Icons.backup,
              title: 'Backup Data',
              subtitle: 'Backup your medication data',
              trailing: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup feature coming soon!')),
                  );
                },
              ),
            ),
            _buildSettingItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'View our privacy policy',
              trailing: IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy policy coming soon!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.0.0 (Milestone 1)',
              trailing: null,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentRoute: '/settings'),
      ),
    );
  }
}
