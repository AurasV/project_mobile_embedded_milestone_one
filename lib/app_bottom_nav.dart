import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'add_pills_form.dart';
import 'pills_provider.dart';

class AppBottomNavigationBar extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavigationBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return BottomAppBar(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home,
              route: '/dashboard',
              isActive: currentRoute == '/dashboard',
            ),
            _buildNavItem(
              context,
              icon: Icons.camera_alt,
              route: '/add_prescription',
              isActive: currentRoute == '/add_prescription',
            ),
            FloatingActionButton(
              onPressed: () async {
                if (currentRoute != '/add_pills_form') {
                  final result = await Navigator.pushNamed(context, '/add_pills_form');
                  // If we got pill data back, add it to the provider
                  if (result != null && result is PillData) {
                    if (context.mounted) {
                      Provider.of<PillsProvider>(context, listen: false).addPill(result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pill added successfully!')),
                      );
                      // Navigate to dashboard if not already there
                      if (currentRoute != '/dashboard') {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      }
                    }
                  }
                }
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.medication, size: 24),
              elevation: 2,
              mini: true,
            ),
            _buildNavItem(
              context,
              icon: Icons.person,
              route: '/profile',
              isActive: currentRoute == '/profile',
            ),
            _buildNavItem(
              context,
              icon: Icons.settings,
              route: '/settings',
              isActive: currentRoute == '/settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String route,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () {
        if (currentRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? theme.colorScheme.primary : Colors.grey,
            size: isActive ? 26 : 22,
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 2),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
