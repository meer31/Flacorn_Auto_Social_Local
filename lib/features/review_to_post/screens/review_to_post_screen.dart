import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/business_categories.dart';
import '../../../core/services/functions_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Review-to-Post Generator (PDF Section 18).
///
/// User pastes a customer review; AI turns it into a ready-to-publish
/// social post with caption, testimonial, story version, hashtags, and
/// a booking CTA. Useful for salons, restaurants, real estate, coaches,
/// and local service businesses.
class ReviewToPostScreen extends ConsumerStatefulWidget {
  const ReviewToPostScreen({super.key});

  @override
  ConsumerState<ReviewToPostScreen> createState() => _ReviewToPostScreenState();
}

class _ReviewToPostScreenState extends ConsumerState<ReviewToPostScreen> {
  final _reviewController = TextEditingController();
  final _ctaController = TextEditingController();
  String _businessType = kBusinessCategories.first;
  String _platform = 'instagram';
  String _tone = kBrandTones.first;
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _reviewController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final review = _reviewController.text.trim();
    if (review.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please paste a customer review first.')));
      return;
    }
    setState(() {
      _loading = true;
      _result = null;
      _error = null;
    });
    try {
      final result = await FunctionsService.instance.generateReviewPost({
        'review': review,
        'businessType': _businessType,
        'platform': _platform,
        'tone': _tone,
        'cta': _ctaController.text.trim().isEmpty ? null : _ctaController.text.trim(),
      });
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (err) {
      setState(() {
        _error = err.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Text('Review to Post', style: AppTextStyles.headlineMedium(AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                  'Paste a customer review and AI will turn it into a social media post.',
                  style: AppTextStyles.bodyMedium(AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _reviewController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Customer review',
                    alignLabelWithHint: true,
                    hintText: '"Amazing experience! The team was so professional and the results exceeded my expectations..."',
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _businessType,
                  decoration: const InputDecoration(labelText: 'Business type'),
                  items: [for (final c in kBusinessCategories) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (v) => setState(() => _businessType = v!),
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
                DropdownButtonFormField<String>(
                  initialValue: _tone,
                  decoration: const InputDecoration(labelText: 'Tone'),
                  items: [for (final t in kBrandTones) DropdownMenuItem(value: t, child: Text(t))],
                  onChanged: (v) => setState(() => _tone = v!),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _ctaController,
                  decoration: const InputDecoration(
                    labelText: 'CTA to include (optional)',
                    hintText: 'e.g. Book now at...',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _generate,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Generate Post from Review'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),

          // ---- Results panel ----
          Expanded(
            child: _loading
                ? ListView.separated(
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => const SkeletonCard(height: 130),
                  )
                : _error != null
                    ? Center(
                        child: Text('Error: $_error',
                            style: AppTextStyles.bodyMedium(AppColors.error)),
                      )
                    : _result == null
                        ? const EmptyState(
                            icon: Icons.star_outline,
                            title: 'No review converted yet',
                            message:
                                'Paste a customer review, choose your settings, and generate a post.',
                          )
                        : _ResultPanel(result: _result!),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.result});
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final hashtags = (result['hashtags'] as List?)?.cast<String>() ?? const [];

    return ListView(
      children: [
        _OutputCard(
          label: 'Social Post Caption',
          icon: Icons.post_add_outlined,
          content: result['caption']?.toString() ?? result['captionText']?.toString() ?? '',
        ),
        const SizedBox(height: 12),
        _OutputCard(
          label: 'Testimonial Post',
          icon: Icons.format_quote_outlined,
          content: result['testimonialPost']?.toString() ?? '',
        ),
        const SizedBox(height: 12),
        _OutputCard(
          label: 'Story Caption',
          icon: Icons.auto_stories_outlined,
          content: result['storyCaption']?.toString() ?? '',
        ),
        const SizedBox(height: 12),
        if (hashtags.isNotEmpty)
          _HashtagCard(hashtags: hashtags),
        const SizedBox(height: 12),
        _OutputCard(
          label: 'Booking CTA',
          icon: Icons.calendar_today_outlined,
          content: result['bookingCta']?.toString() ?? result['cta']?.toString() ?? '',
          accentColor: AppColors.flacronRed,
        ),
      ],
    );
  }
}

class _OutputCard extends StatelessWidget {
  const _OutputCard({
    required this.label,
    required this.icon,
    required this.content,
    this.accentColor,
  });
  final String label;
  final IconData icon;
  final String content;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
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
          Row(
            children: [
              Icon(icon, size: 16, color: accentColor ?? AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.caption(accentColor ?? AppColors.textSecondary)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 16),
                tooltip: 'Copy',
                color: AppColors.textMuted,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$label copied')));
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _HashtagCard extends StatelessWidget {
  const _HashtagCard({required this.hashtags});
  final List<String> hashtags;

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              const Icon(Icons.tag_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('Hashtags', style: AppTextStyles.caption(AppColors.textSecondary)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 16),
                tooltip: 'Copy all',
                color: AppColors.textMuted,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: hashtags.join(' ')));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Hashtags copied')));
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in hashtags)
                Chip(label: Text(tag, style: AppTextStyles.bodySmall(AppColors.textSecondary))),
            ],
          ),
        ],
      ),
    );
  }
}
