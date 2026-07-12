import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../routing/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/global_search/screens/global_search_screen.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

const List<_NavItem> _navItems = [
  _NavItem('Dashboard', Icons.dashboard_outlined, AppRoutes.dashboard),
  _NavItem('Accounts', Icons.link, AppRoutes.connectedAccounts),
  _NavItem('AI Generator', Icons.auto_awesome_outlined, AppRoutes.aiContentGenerator),
  _NavItem('Content Calendar', Icons.calendar_month_outlined, AppRoutes.contentCalendar),
  _NavItem('Campaigns', Icons.campaign_outlined, AppRoutes.campaigns),
  _NavItem('Scheduler', Icons.schedule_outlined, AppRoutes.scheduler),
  _NavItem('Templates', Icons.article_outlined, AppRoutes.templates),
  _NavItem('Analytics', Icons.bar_chart_outlined, AppRoutes.analytics),
  _NavItem('Weekly Reports', Icons.insights_outlined, AppRoutes.weeklyReports),
  _NavItem('AR Campaigns', Icons.view_in_ar_outlined, AppRoutes.arCampaigns),
  _NavItem('Media Library', Icons.perm_media_outlined, AppRoutes.mediaLibrary),
  _NavItem('Brand Kit', Icons.palette_outlined, AppRoutes.brandKit),
  _NavItem('Team', Icons.group_outlined, AppRoutes.team),
  _NavItem('Agency', Icons.groups_outlined, AppRoutes.agencyWorkspace),
  _NavItem('Billing', Icons.credit_card_outlined, AppRoutes.billing),
  _NavItem('Settings', Icons.settings_outlined, AppRoutes.settings),
];

/// Desktop sidebar navigation (PDF Section 24: Flutter Screens Required).
class SidebarNav extends StatelessWidget {
  const SidebarNav({required this.currentPath, super.key});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.flacronRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppConstants.appName,
                    style: AppTextStyles.titleMedium(AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // ---- Global search entry point ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Material(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => GlobalSearchScreen.showAsDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 10),
                      Text('Search…', style: AppTextStyles.bodyMedium(AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isActive = currentPath == item.route;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isActive ? AppColors.flacronRed.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => context.go(item.route),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isActive ? AppColors.flacronRed : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.label,
                              style: AppTextStyles.bodyMedium(
                                isActive ? AppColors.flacronRed : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
