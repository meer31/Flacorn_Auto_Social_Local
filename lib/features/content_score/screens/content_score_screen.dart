import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/functions_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// AI Content Score (PDF Section 20).
///
/// Before scheduling a post, the app shows a score from 0–100 based on:
/// hook strength, clarity, CTA quality, hashtag quality, platform fit,
/// conversion potential, and emotional appeal. Increases user confidence
/// and makes the app feel more professional.
class ContentScoreScreen extends ConsumerStatefulWidget {
  const ContentScoreScreen({super.key});

  @override
  ConsumerState<ContentScoreScreen> createState() => _ContentScoreScreenState();
}

class _ContentScoreScreenState extends ConsumerState<ContentScoreScreen> {
  final _captionController = TextEditingController();
  final _hashtagsController = TextEditingController();
  final _ctaController = TextEditingController();
  String _platform = 'instagram';
  bool _loading = false;
  Map<String, dynamic>? _scoreResult;
  String? _error;

  @override
  void dispose() {
    _captionController.dispose();
    _hashtagsController.dispose();
    _ctaController.dispose();
    super.dispose();
  }

  Future<void> _score() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a caption to score.')));
      return;
    }
    setState(() {
      _loading = true;
      _scoreResult = null;
      _error = null;
    });
    try {
      final result = await FunctionsService.instance.generateContentScore({
        'captionText': caption,
        'hashtags': _hashtagsController.text.trim().isEmpty
            ? []
            : _hashtagsController.text
                .trim()
                .split(RegExp(r'[\s,]+'))
                .where((h) => h.isNotEmpty)
                .toList(),
        'cta': _ctaController.text.trim().isEmpty ? null : _ctaController.text.trim(),
        'platform': _platform,
      });
      setState(() {
        _scoreResult = result;
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
                Text('Content Score', style: AppTextStyles.headlineMedium(AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                  'Score your post from 0–100 before you schedule it. Improve weak areas with AI recommendations.',
                  style: AppTextStyles.bodyMedium(AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _captionController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Caption',
                    alignLabelWithHint: true,
                    hintText: 'Paste your caption here...',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _hashtagsController,
                  decoration: const InputDecoration(
                    labelText: 'Hashtags (optional)',
                    hintText: '#hair #beauty #salon',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _ctaController,
                  decoration: const InputDecoration(
                    labelText: 'CTA included (optional)',
                    hintText: 'e.g. Book now at...',
                  ),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _score,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Score My Content'),
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
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, __) => const SkeletonCard(height: 80),
                  )
                : _error != null
                    ? Center(
                        child: Text('Error: $_error',
                            style: AppTextStyles.bodyMedium(AppColors.error)),
                      )
                    : _scoreResult == null
                        ? const EmptyState(
                            icon: Icons.analytics_outlined,
                            title: 'No score yet',
                            message:
                                'Enter your caption and tap "Score My Content" to get an AI quality rating.',
                          )
                        : _ScorePanel(result: _scoreResult!),
          ),
        ],
      ),
    );
  }
}

/// Renders the full score breakdown returned from [generateContentScore].
class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.result});
  final Map<String, dynamic> result;

  Color _scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 55) return AppColors.warning;
    return AppColors.error;
  }

  String _scoreLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 65) return 'Good';
    if (score >= 50) return 'Average';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = (result['contentScore'] ?? result['score'] ?? 0) as int;
    final recommendation =
        result['recommendation']?.toString() ?? result['summary']?.toString() ?? '';
    final breakdown = result['breakdown'] as Map<String, dynamic>? ?? {};

    final scoreColor = _scoreColor(totalScore);

    return ListView(
      children: [
        // ---- Big score circle ----
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: totalScore / 100,
                      strokeWidth: 10,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalScore',
                        style: AppTextStyles.headlineLarge(scoreColor),
                      ),
                      Text('/100', style: AppTextStyles.bodySmall(AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(_scoreLabel(totalScore),
                  style: AppTextStyles.titleMedium(scoreColor)),
              if (recommendation.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  recommendation,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),

        // ---- Breakdown bars ----
        if (breakdown.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score Breakdown',
                    style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                const SizedBox(height: 16),
                for (final entry in breakdown.entries) ...[
                  _ScoreBar(
                    label: _formatLabel(entry.key),
                    score: (entry.value as num).toInt(),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],

        // ---- Default breakdown when backend returns only total ----
        if (breakdown.isEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Scoring Criteria',
                    style: AppTextStyles.titleMedium(AppColors.textPrimary)),
                const SizedBox(height: 12),
                for (final label in [
                  'Hook strength',
                  'Clarity',
                  'CTA quality',
                  'Hashtag quality',
                  'Platform fit',
                  'Conversion potential',
                  'Emotional appeal',
                ]) ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(label, style: AppTextStyles.bodyMedium(AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatLabel(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'([A-Z])'), ' \$1')
        .trim()
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.score});
  final String label;
  final int score;

  Color get _barColor {
    if (score >= 80) return AppColors.success;
    if (score >= 55) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium(AppColors.textPrimary)),
            Text('$score/100', style: AppTextStyles.caption(_barColor)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(_barColor),
          ),
        ),
      ],
    );
  }
}
