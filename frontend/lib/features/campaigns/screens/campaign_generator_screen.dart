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

/// Campaign Generator (PDF Section 13) — Pro/Agency feature.
class CampaignGeneratorScreen extends ConsumerStatefulWidget {
  const CampaignGeneratorScreen({super.key});

  @override
  ConsumerState<CampaignGeneratorScreen> createState() => _CampaignGeneratorScreenState();
}

class _CampaignGeneratorScreenState extends ConsumerState<CampaignGeneratorScreen> {
  String _campaignType = kCampaignTypes.first;
  bool _generating = false;

  Future<void> _generate() async {
    setState(() => _generating = true);
    try {
      await ref.read(contentRepositoryProvider).generateCampaign({
        'campaignName': _campaignType,
        'campaignType': _campaignType,
        'businessCategory': kBusinessCategories.first,
        'goal': 'Get more bookings',
        'tone': 'Friendly',
        'postCount': 10,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'arEnabled': false,
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
    final canUseCampaigns =
        subscription?.planName == 'pro' || subscription?.planName == 'agency' || subscription?.planName == 'enterprise';

    if (uid == null) return const SizedBox.shrink();
    final campaignsAsync = ref.watch(_campaignsProvider(uid));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Campaign Generator', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Launch a themed campaign with 5-15 posts, stories, and reel ideas.',
              style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
          const SizedBox(height: 20),
          if (!canUseCampaigns) ...[
            const UpgradePromptBanner(message: 'The Campaign Generator is available on Pro and Agency plans.'),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _campaignType,
                  decoration: const InputDecoration(labelText: 'Campaign type'),
                  items: [for (final c in kCampaignTypes) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: canUseCampaigns ? (v) => setState(() => _campaignType = v!) : null,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: canUseCampaigns && !_generating ? _generate : null,
                child: _generating
                    ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Generate Campaign'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: campaignsAsync.when(
              loading: () => ListView.separated(
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const SkeletonCard(height: 90),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return const EmptyState(
                    icon: Icons.campaign_outlined,
                    title: 'No campaigns yet',
                    message: 'Pick a campaign type above and generate your first themed campaign.',
                  );
                }
                return ListView.separated(
                  itemCount: campaigns.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = campaigns[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.campaignName, style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text('${c.campaignType} · ${c.posts.length} posts · ${c.status}',
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

final _campaignsProvider = StreamProvider.family((ref, String userId) {
  return ref.watch(contentRepositoryProvider).watchCampaigns(userId);
});
