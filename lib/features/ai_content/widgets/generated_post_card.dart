import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Card rendering a single AI-generated post with the actions described in
/// PDF Section 11 ("Required Actions"): Edit, Save as template, Schedule,
/// Regenerate caption, Rewrite tone, Create AR preview if plan allows.
class GeneratedPostCard extends StatelessWidget {
  const GeneratedPostCard({
    required this.post,
    required this.onEdit,
    required this.onSchedule,
    required this.onRegenerate,
    this.onCreateArPreview,
    super.key,
  });

  final Map<String, dynamic> post;
  final VoidCallback onEdit;
  final VoidCallback onSchedule;
  final VoidCallback onRegenerate;
  final VoidCallback? onCreateArPreview;

  @override
  Widget build(BuildContext context) {
    final hashtags = (post['hashtags'] as List?)?.cast<String>() ?? const [];
    final score = post['contentScore'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(post['title']?.toString() ?? 'Untitled post',
                    style: AppTextStyles.titleMedium(AppColors.textPrimary)),
              ),
              if (score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Score: $score/100',
                      style: AppTextStyles.caption(AppColors.success)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(post['captionText']?.toString() ?? '', style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in hashtags) Chip(label: Text(tag, style: AppTextStyles.bodySmall(AppColors.textSecondary))),
            ],
          ),
          const SizedBox(height: 10),
          Text('CTA: ${post['cta'] ?? ''}', style: AppTextStyles.bodySmall(AppColors.textMuted)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: onEdit, child: const Text('Edit')),
              OutlinedButton(onPressed: onRegenerate, child: const Text('Regenerate')),
              if (onCreateArPreview != null)
                OutlinedButton(onPressed: onCreateArPreview, child: const Text('AR Preview')),
              ElevatedButton(onPressed: onSchedule, child: const Text('Schedule')),
            ],
          ),
        ],
      ),
    );
  }
}
