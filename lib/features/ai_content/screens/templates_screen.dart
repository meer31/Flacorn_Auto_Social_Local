import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Templates screen (PDF Section 24) — saved post templates the user can
/// reuse, edit, or schedule (postTemplates/{templateId}).
class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return const SizedBox.shrink();

    final templatesAsync = ref.watch(_templatesStreamProvider(uid));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Templates', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text('Reusable post templates saved from the AI Content Generator.',
              style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
          const SizedBox(height: 20),
          Expanded(
            child: templatesAsync.when(
              loading: () => ListView.separated(
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, __) => const SkeletonCard(height: 80),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (templates) {
                if (templates.isEmpty) {
                  return const EmptyState(
                    icon: Icons.article_outlined,
                    title: 'No templates saved yet',
                    message: 'Generate content and save your favorite posts as templates.',
                  );
                }
                return ListView.separated(
                  itemCount: templates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final t = templates[index];
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
                          Text(t.title, style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(t.captionText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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

final _templatesStreamProvider = StreamProvider.family((ref, String userId) {
  return ref.watch(contentRepositoryProvider).watchTemplates(userId);
});
