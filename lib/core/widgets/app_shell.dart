import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import 'sidebar_nav.dart';
import 'bottom_nav.dart';

/// Persistent app shell wrapping every "main app" screen (PDF Section 24).
/// Uses a sidebar on desktop/tablet (>= 900px) and a bottom nav bar on
/// mobile widths, satisfying the "Sidebar navigation for desktop, Bottom
/// navigation for mobile" UI/UX requirement.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const double _desktopBreakpoint = 900;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= _desktopBreakpoint;
    final currentPath = GoRouterState.of(context).matchedLocation;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            SidebarNav(currentPath: currentPath),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: BottomNav(currentPath: currentPath),
    );
  }
}
