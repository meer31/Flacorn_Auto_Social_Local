import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/upgrade_prompt_banner.dart';
import '../providers/onboarding_provider.dart';

/// Onboarding Steps 7 & 8 (PDF Section 8):
///   Step 7: Generate First Content Plan — the app generates 7 sample posts
///           immediately, so the user sees value before paying.
///   Step 8: Upgrade / Schedule Prompt — if the user hasn't paid yet, show
///           "Your first content plan is ready. Upgrade to schedule and
///           auto-publish your posts."
class FirstContentPlanResultScreen extends ConsumerStatefulWidget {
  const FirstContentPlanResultScreen({super.key});

  @override
  ConsumerState<FirstContentPlanResultScreen> createState() =>
      _FirstContentPlanResultScreenState();
}

class _FirstContentPlanResultScreenState extends ConsumerState<FirstContentPlanResultScreen> {
  List<dynamic>? _posts;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateSamplePosts());
  }

  Future<void> _generateSamplePosts() async {
    final draft = ref.read(onboardingControllerProvider);
    try {
      final result = await ref.read(contentRepositoryProvider).generatePosts({
        'niche': draft.businessCategory,
        'businessCategory': draft.businessCategory,
        'goal': draft.mainGoal,
        'tone': draft.brandTone,
        'numberOfPosts': 7,
        'platform': 'instagram',
      });
      setState(() {
        _posts = result['posts'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (err) {
      setState(() {
        _errorMessage = 'We could not generate your sample plan right now. $err';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;
    final hasPaid = subscription?.isActive ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Your first content plan is ready 🎉',
                      style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(
                    'Here are 7 posts we generated for your business.',
                    style: AppTextStyles.bodyMedium(AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  if (!hasPaid)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: UpgradePromptBanner(
                        message:
                            'Your first content plan is ready. Upgrade to schedule and auto-publish your posts.',
                        ctaLabel: 'Upgrade Now',
                      ),
                    ),
                  Expanded(
                    child: _loading
                        ? ListView.separated(
                            itemCount: 5,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, __) => const SkeletonCard(height: 90),
                          )
                        : _errorMessage != null
                            ? Center(
                                child: Text(_errorMessage!,
                                    style: AppTextStyles.bodyMedium(AppColors.error)),
                              )
                            : ListView.separated(
                                itemCount: _posts?.length ?? 0,
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final post = _posts![index] as Map<String, dynamic>;
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post['title']?.toString() ?? 'Post idea',
                                            style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                                        const SizedBox(height: 6),
                                        Text(
                                          post['captionText']?.toString() ?? '',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodySmall(AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.dashboard),
                    child: const Text('Go to Dashboard'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
