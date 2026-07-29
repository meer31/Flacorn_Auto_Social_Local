import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/upgrade_prompt_banner.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/quick_action_button.dart';

/// Dashboard — the app's command center (PDF Section 23).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;
    final scheduledPosts = ref.watch(dashboardScheduledPostsProvider).valueOrNull ?? [];
    final accounts = ref.watch(dashboardSocialAccountsProvider).valueOrNull ?? [];

    final now = DateTime.now();
    final todayPosts = scheduledPosts.where((p) =>
        p.scheduledAt.year == now.year && p.scheduledAt.month == now.month && p.scheduledAt.day == now.day);
    final failedPosts = scheduledPosts.where((p) => p.status == 'failed').toList();
    final needsReconnect = accounts.where((a) => a.needsReconnect).toList();
    final pendingSorted = scheduledPosts.where((p) => p.status == 'pending').toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final nextPost = pendingSorted.isNotEmpty ? pendingSorted.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back${profile?.businessName.isNotEmpty == true ? ', ${profile!.businessName}' : ''}',
                    style: AppTextStyles.headlineLarge(AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Here's what's happening with your content today.",
                    style: AppTextStyles.bodyMedium(AppColors.textSecondary),
                  ),
                ],
              ),
              if (subscription != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.flacronGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subscription.planName.toUpperCase(),
                    style: AppTextStyles.labelLarge(AppColors.flacronBlack),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (needsReconnect.isNotEmpty) ...[
            UpgradePromptBanner(
              message:
                  '${needsReconnect.first.platform[0].toUpperCase()}${needsReconnect.first.platform.substring(1)} needs reconnecting to keep publishing on schedule.',
              ctaLabel: 'Reconnect',
            ),
            const SizedBox(height: 16),
          ],
          if (subscription != null &&
              subscription.aiGenerationLimit != null &&
              subscription.aiGenerationsUsed >= subscription.aiGenerationLimit!) ...[
            UpgradePromptBanner(
              message:
                  'You reached your ${subscription.planName} AI limit. Upgrade to Pro for 300 AI generations and unlimited scheduling.',
            ),
            const SizedBox(height: 16),
          ],

          // ---- Top cards ----
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final cards = [
                StatCard(
                  label: 'AI Generations',
                  value: subscription == null
                      ? '—'
                      : '${subscription.aiGenerationsUsed}${subscription.aiGenerationLimit != null ? ' / ${subscription.aiGenerationLimit}' : ''}',
                  icon: Icons.auto_awesome_outlined,
                ),
                StatCard(
                  label: 'Scheduled This Month',
                  value: subscription == null
                      ? '—'
                      : '${subscription.scheduledPostsUsed}${subscription.scheduledPostLimit != null ? ' / ${subscription.scheduledPostLimit}' : ' (unlimited)'}',
                  icon: Icons.schedule_outlined,
                ),
                StatCard(
                  label: 'Connected Accounts',
                  value: '${accounts.length}${subscription?.socialAccountLimit != null ? ' / ${subscription!.socialAccountLimit}' : ''}',
                  icon: Icons.link,
                ),
                StatCard(
                  label: 'Failed Posts',
                  value: '${failedPosts.length}',
                  icon: Icons.error_outline,
                  accentColor: failedPosts.isEmpty ? AppColors.success : AppColors.error,
                ),
              ];
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: cards,
              );
            },
          ),
          const SizedBox(height: 28),

          Text('Quick Actions', style: AppTextStyles.headlineSmall(AppColors.textPrimary)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  QuickActionButton(
                    icon: Icons.calendar_month_outlined,
                    label: 'Generate 30-Day Plan',
                    onTap: () => context.go(AppRoutes.contentCalendar),
                  ),
                  QuickActionButton(
                    icon: Icons.auto_awesome_outlined,
                    label: 'Create New Post',
                    onTap: () => context.go(AppRoutes.aiContentGenerator),
                  ),
                  QuickActionButton(
                    icon: Icons.schedule_outlined,
                    label: 'Schedule Post',
                    onTap: () => context.go(AppRoutes.scheduler),
                  ),
                  QuickActionButton(
                    icon: Icons.link,
                    label: 'Connect Social Account',
                    onTap: () => context.go(AppRoutes.connectedAccounts),
                  ),
                  QuickActionButton(
                    icon: Icons.campaign_outlined,
                    label: 'Create Campaign',
                    onTap: () => context.go(AppRoutes.campaigns),
                  ),
                  QuickActionButton(
                    icon: Icons.view_in_ar_outlined,
                    label: 'Create AR Campaign',
                    onTap: () => context.go(AppRoutes.arCampaigns),
                  ),
                  QuickActionButton(
                    icon: Icons.bar_chart_outlined,
                    label: 'View Analytics',
                    onTap: () => context.go(AppRoutes.analytics),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          Text("Today's Summary", style: AppTextStyles.headlineSmall(AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Scheduled Today',
                  value: '${todayPosts.length}',
                  icon: Icons.today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Published Today',
                  value: '${todayPosts.where((p) => p.status == 'sent').length}',
                  icon: Icons.check_circle_outline,
                  accentColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  label: 'Next Post',
                  value: nextPost == null
                      ? 'None scheduled'
                      : '${nextPost.scheduledAt.hour.toString().padLeft(2, '0')}:${nextPost.scheduledAt.minute.toString().padLeft(2, '0')}',
                  icon: Icons.upcoming_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          if (scheduledPosts.isEmpty)
            const EmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'You have no posts scheduled this week',
              message: 'Generate a 30-day content plan or create a single post to get started.',
            ),
        ],
      ),
    );
  }
}
