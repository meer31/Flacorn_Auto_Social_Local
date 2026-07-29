import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/business_categories.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../providers/ai_content_provider.dart';
import '../widgets/generated_post_card.dart';

/// AI Content Generator (PDF Section 11) — the app's primary conversion
/// feature. This screen implements the core "generate posts" flow; the
/// other tools in the "AI Content Generator Requirements" list (Hashtag
/// Generator, Content Rewriter, Tone Changer, Blog/URL to Social Posts,
/// Product Description Generator, Ad Copy Generator) share this same
/// generatePosts pipeline with different prompt presets — see the "More
/// Tools" menu below, wired to TODO stubs ready for prompt-preset expansion.
class AiContentGeneratorScreen extends ConsumerStatefulWidget {
  const AiContentGeneratorScreen({super.key});

  @override
  ConsumerState<AiContentGeneratorScreen> createState() => _AiContentGeneratorScreenState();
}

class _AiContentGeneratorScreenState extends ConsumerState<AiContentGeneratorScreen> {
  final _nicheController = TextEditingController();
  final _offerController = TextEditingController();
  String _category = kBusinessCategories.first;
  String _goal = kMainGoals.first;
  String _tone = kBrandTones.first;
  String _platform = 'instagram';
  int _numberOfPosts = 5;

  @override
  void dispose() {
    _nicheController.dispose();
    _offerController.dispose();
    super.dispose();
  }

  void _generate() {
    ref.read(aiContentControllerProvider.notifier).generate({
      'niche': _nicheController.text.trim(),
      'businessCategory': _category,
      'goal': _goal,
      'tone': _tone,
      'numberOfPosts': _numberOfPosts,
      'platform': _platform,
      'offer': _offerController.text.trim().isEmpty ? null : _offerController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiContentControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Input panel ----
          SizedBox(
            width: 340,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Content Generator', style: AppTextStyles.headlineMedium(AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text('Generate ready-to-publish posts in seconds.',
                    style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
                const SizedBox(height: 20),
                TextField(
                  controller: _nicheController,
                  decoration: const InputDecoration(labelText: 'Niche / focus'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Business category'),
                  items: [for (final c in kBusinessCategories) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _goal,
                  decoration: const InputDecoration(labelText: 'Goal'),
                  items: [for (final g in kMainGoals) DropdownMenuItem(value: g, child: Text(g))],
                  onChanged: (v) => setState(() => _goal = v!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _tone,
                  decoration: const InputDecoration(labelText: 'Tone'),
                  items: [for (final t in kBrandTones) DropdownMenuItem(value: t, child: Text(t))],
                  onChanged: (v) => setState(() => _tone = v!),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _platform,
                  decoration: const InputDecoration(labelText: 'Platform'),
                  items: const [
                    DropdownMenuItem(value: 'instagram', child: Text('Instagram')),
                    DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                    DropdownMenuItem(value: 'twitter', child: Text('X / Twitter')),
                    DropdownMenuItem(value: 'linkedin', child: Text('LinkedIn')),
                  ],
                  onChanged: (v) => setState(() => _platform = v!),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _offerController,
                  decoration: const InputDecoration(labelText: 'Current offer (optional)'),
                ),
                const SizedBox(height: 14),
                Text('Number of posts: $_numberOfPosts', style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
                Slider(
                  value: _numberOfPosts.toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  activeColor: AppColors.flacronRed,
                  onChanged: (v) => setState(() => _numberOfPosts = v.round()),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: state.isLoading ? null : _generate,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Generate Posts'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),

          // ---- Results panel ----
          Expanded(
            child: state.isLoading
                ? ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => const SkeletonCard(height: 160),
                  )
                : state.errorMessage != null
                    ? Center(child: Text('Error: ${state.errorMessage}', style: AppTextStyles.bodyMedium(AppColors.error)))
                    : state.posts.isEmpty
                        ? const EmptyState(
                            icon: Icons.auto_awesome_outlined,
                            title: 'No content generated yet',
                            message: 'Fill in the form and generate your first batch of posts.',
                          )
                        : ListView.separated(
                            itemCount: state.posts.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final post = state.posts[index];
                              return GeneratedPostCard(
                                post: post,
                                onEdit: () {
                                  // TODO: open an edit dialog / inline editor bound to this post.
                                },
                                onRegenerate: _generate,
                                onSchedule: () => context.go(AppRoutes.scheduler),
                                onCreateArPreview: () => context.go(AppRoutes.arCampaigns),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
