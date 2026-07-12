import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';

/// Mobile bottom navigation — a focused subset of the full sidebar, since
/// mobile screens can't comfortably fit all 15 main-app destinations.
/// The rest remain reachable via Settings > More or the Dashboard quick
/// actions grid.
class BottomNav extends StatelessWidget {
  const BottomNav({required this.currentPath, super.key});

  final String currentPath;

  static const _items = [
    (AppRoutes.dashboard, Icons.dashboard_outlined, 'Home'),
    (AppRoutes.aiContentGenerator, Icons.auto_awesome_outlined, 'Create'),
    (AppRoutes.scheduler, Icons.schedule_outlined, 'Schedule'),
    (AppRoutes.analytics, Icons.bar_chart_outlined, 'Analytics'),
    (AppRoutes.settings, Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _items.indexWhere((i) => i.$1 == currentPath).clamp(0, _items.length - 1);

    return NavigationBar(
      selectedIndex: currentIndex == -1 ? 0 : currentIndex,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.flacronRed.withValues(alpha: 0.12),
      onDestinationSelected: (index) => context.go(_items[index].$1),
      destinations: [
        for (final item in _items)
          NavigationDestination(icon: Icon(item.$2), label: item.$3),
      ],
    );
  }
}
