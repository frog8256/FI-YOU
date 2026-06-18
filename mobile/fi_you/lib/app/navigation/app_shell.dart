import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_theme.dart';
import '../../core/widgets/app_background.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(bottom: false, child: child),
        bottomNavigationBar: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _indexFor(location),
            height: 70,
            backgroundColor: FiYouColors.panelDeep.withValues(alpha: 0.96),
            indicatorColor: FiYouColors.violet.withValues(alpha: 0.20),
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) => context.go(_pathFor(index)),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Today'),
              NavigationDestination(icon: Icon(Icons.edit_note_outlined), label: 'Diary'),
              NavigationDestination(icon: Icon(Icons.hub_outlined), label: 'U-Map'),
              NavigationDestination(icon: Icon(Icons.waves_outlined), label: 'Signature'),
              NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  int _indexFor(String location) {
    if (location.startsWith('/diary')) return 1;
    if (location.startsWith('/u-map')) return 2;
    if (location.startsWith('/signature')) return 3;
    if (location.startsWith('/settings') ||
        location.startsWith('/legal') ||
        location.startsWith('/relations') ||
        location.startsWith('/reports') ||
        location.startsWith('/store')) {
      return 4;
    }
    return 0;
  }

  String _pathFor(int index) {
    return switch (index) {
      1 => '/diary',
      2 => '/u-map',
      3 => '/signature',
      4 => '/settings',
      _ => '/today',
    };
  }
}
