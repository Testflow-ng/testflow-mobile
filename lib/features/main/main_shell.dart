import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import 'widgets/app_nav_bar.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _destinations = [
    AppNavDestination(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    AppNavDestination(
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note_rounded,
      label: 'Practice',
    ),
    AppNavDestination(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_rounded,
      label: 'History',
    ),
    AppNavDestination(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const _routes = [
    AppRoutes.home,
    AppRoutes.practice,
    AppRoutes.history,
    AppRoutes.profile,
  ];

  int _locationToIndex(String location) {
    for (var i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: AppNavBar(
        destinations: _destinations,
        currentIndex: _locationToIndex(location),
        onSelected: (index) => context.go(_routes[index]),
      ),
    );
  }
}
