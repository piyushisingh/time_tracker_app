import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.timer_rounded,
                    size: 48,
                    color: colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Time Tracker',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your time efficiently',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),

          // ── Menu Items ──────────────────────────────────────────
          ListTile(
            leading: Icon(Icons.home_rounded, color: colorScheme.primary),
            title: const Text('Home'),
            onTap: () {
              Navigator.of(context).pop(); // close drawer
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.folder_rounded, color: colorScheme.primary),
            title: const Text('Projects'),
            subtitle: const Text('Manage your projects'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/projects');
            },
          ),
          ListTile(
            leading: Icon(Icons.task_alt_rounded, color: colorScheme.primary),
            title: const Text('Tasks'),
            subtitle: const Text('Manage your tasks'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/tasks');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.storage_rounded, color: colorScheme.tertiary),
            title: const Text('Local Storage'),
            subtitle: const Text('Debug data view'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/storage');
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
