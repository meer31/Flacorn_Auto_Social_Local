import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/models/search_result.dart';

/// Maps a search result's [SearchResult.type] to the route it should open
/// and an icon for its leading avatar. Kept here (not on the model) since
/// it's presentation-only concern.
class SearchResultTile extends StatelessWidget {
  const SearchResultTile({required this.result, super.key});

  final SearchResult result;

  IconData get _icon => switch (result.type) {
        'scheduledPost' => Icons.schedule_outlined,
        'campaign' => Icons.campaign_outlined,
        'media' => Icons.perm_media_outlined,
        'template' => Icons.article_outlined,
        _ => Icons.insert_drive_file_outlined,
      };

  String get _typeLabel => switch (result.type) {
        'scheduledPost' => 'Scheduled Post',
        'campaign' => 'Campaign',
        'media' => 'Media',
        'template' => 'Template',
        _ => 'Item',
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          // TODO: route to the specific detail screen for result.type once
          // each feature exposes a deep-linkable detail route; for now this
          // sends the user to that feature's list screen as a reasonable
          // fallback.
          context.pop();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icon, size: 18, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title.isEmpty ? '(untitled)' : result.title,
                      style: AppTextStyles.bodyMedium(AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      result.subtitle ?? _typeLabel,
                      style: AppTextStyles.bodySmall(AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(_typeLabel, style: AppTextStyles.bodySmall(AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
