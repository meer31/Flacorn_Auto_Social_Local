import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/business_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/upgrade_prompt_banner.dart';

/// 30-Day AI Content Calendar (PDF Section 12).
/// "Generate My 30-Day Content Plan" — a Pro/Agency feature; Starter users
/// see an upgrade prompt instead of the generate button.
class ContentCalendarScreen extends ConsumerStatefulWidget {
  const ContentCalendarScreen({super.key});

  @override
  ConsumerState<ContentCalendarScreen> createState() => _ContentCalendarScreenState();
}

class _ContentCalendarScreenState extends ConsumerState<ContentCalendarScreen> {
  bool _generating = false;
  final String _category = kBusinessCategories.first;
  final String _goal = kMainGoals.first;

  Future<void> _generatePlan() async {
    setState(() => _generating = true);
    try {
      await ref.read(contentRepositoryProvider).generateContentPlan({
        'planName': '30-Day Plan — ${DateTime.now().toIso8601String().split('T').first}',
        'niche': _category,
        'businessCategory': _category,
        'goal': _goal,
        'tone': 'Friendly',
        'platform': 'instagram',
        'days': 30,
      });
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Generation failed: $err')));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;
    final canUse30Day = subscription?.planName == 'pro' ||
        subscription?.planName == 'agency' ||
        subscription?.planName == 'enterprise';

    if (uid == null) return const SizedBox.shrink();
    final plansAsync = ref.watch(_contentPlansProvider(uid));

    return Padding(
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
                  Text('30-Day Content Calendar', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text('A full month of posts, generated in one click.',
                      style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
                ],
              ),
              if (canUse30Day)
                ElevatedButton.icon(
                  onPressed: _generating ? null : _generatePlan,
                  icon: _generating
                      ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome_outlined),
                  label: const Text('Generate My 30-Day Plan'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (!canUse30Day) ...[
            const UpgradePromptBanner(
              message: '30-day AI content calendars are available on Pro and Agency plans.',
            ),
            const SizedBox(height: 20),
          ],
          Expanded(
            child: plansAsync.when(
              loading: () => ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const SkeletonCard(height: 100),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (plans) {
                if (plans.isEmpty) {
                  return const EmptyState(
                    icon: Icons.calendar_month_outlined,
                    title: 'No content plans yet',
                    message: 'Generate your first 30-day plan to fill your calendar automatically.',
                  );
                }
                return ListView.separated(
                  itemCount: plans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(plan.planName, style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Text('${plan.posts.length} posts · ${plan.status}',
                                    style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          TextButton(onPressed: () {}, child: const Text('View')),
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

final _contentPlansProvider = StreamProvider.family((ref, String userId) {
  return ref.watch(contentRepositoryProvider).watchContentPlans(userId);
});
