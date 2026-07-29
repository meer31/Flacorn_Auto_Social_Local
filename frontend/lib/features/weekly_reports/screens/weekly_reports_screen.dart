import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/upgrade_prompt_banner.dart';

/// Weekly AI Performance Report (PDF Section 16) — Pro/Agency feature.
class WeeklyReportsScreen extends ConsumerWidget {
  const WeeklyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;
    final hasAccess =
        subscription?.planName == 'pro' || subscription?.planName == 'agency' || subscription?.planName == 'enterprise';

    if (uid == null) return const SizedBox.shrink();
    final reportsAsync = ref.watch(_weeklyReportsProvider(uid));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly AI Reports', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Automated weekly summaries with AI recommendations.',
              style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
          const SizedBox(height: 20),
          if (!hasAccess) ...[
            const UpgradePromptBanner(message: 'Weekly AI performance reports are available on Pro and Agency plans.'),
            const SizedBox(height: 20),
          ],
          Expanded(
            child: reportsAsync.when(
              loading: () => ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const SkeletonCard(height: 120),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (reports) {
                if (reports.isEmpty) {
                  return const EmptyState(
                    icon: Icons.insights_outlined,
                    title: 'No reports yet',
                    message: 'Your first weekly report will appear here after 7 days of published posts.',
                  );
                }
                return ListView.separated(
                  itemCount: reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = reports[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Week of ${r['weekOf']?.toString().split('T').first ?? '—'}',
                              style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                          const SizedBox(height: 8),
                          Text('Posts published: ${r['postsPublished'] ?? 0}',
                              style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                          Text('Most effective platform: ${r['mostEffectivePlatform'] ?? '—'}',
                              style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                          Text('Best CTA: ${r['bestCta'] ?? '—'}',
                              style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                          Text('Suggested frequency: ${r['suggestedPostingFrequency'] ?? '—'}',
                              style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

final _weeklyReportsProvider = StreamProvider.family((ref, String userId) {
  return ref.watch(analyticsRepositoryProvider).watchWeeklyReports(userId);
});
