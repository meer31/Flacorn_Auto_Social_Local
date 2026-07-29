import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/user_providers.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/upgrade_prompt_banner.dart';

/// Analytics screen (PDF Section 15).
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _rangeDays = 30;
  Map<String, dynamic>? _summary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ref.read(analyticsRepositoryProvider).getSummary(rangeDays: _rangeDays);
    if (mounted) {
      setState(() {
        _summary = result;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(currentSubscriptionProvider).valueOrNull;
    final hasAdvanced = subscription?.planName == 'pro' ||
        subscription?.planName == 'agency' ||
        subscription?.planName == 'enterprise';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Analytics', style: AppTextStyles.headlineLarge(AppColors.textPrimary)),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 days')),
                  ButtonSegment(value: 30, label: Text('30 days')),
                ],
                selected: {_rangeDays},
                onSelectionChanged: (v) {
                  setState(() => _rangeDays = v.first);
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasAdvanced) ...[
            const UpgradePromptBanner(message: 'Advanced analytics are available on Pro and Agency plans.'),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _loading
                ? GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: List.generate(4, (_) => const SkeletonCard()),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 800;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isWide ? 4 : 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                            children: [
                              StatCard(
                                label: 'Total Reach',
                                value: '${_summary?['totalReach'] ?? 0}',
                                icon: Icons.groups_outlined,
                              ),
                              StatCard(
                                label: 'Total Engagement',
                                value: '${_summary?['totalEngagementActions'] ?? 0}',
                                icon: Icons.favorite_border,
                              ),
                              StatCard(
                                label: 'Engagement Rate',
                                value: '${_summary?['overallEngagementRate'] ?? 0}%',
                                icon: Icons.percent,
                              ),
                              StatCard(
                                label: 'Best Time (UTC)',
                                value: _summary?['bestTimeToPostUtcHour'] != null
                                    ? '${_summary!['bestTimeToPostUtcHour']}:00'
                                    : '—',
                                icon: Icons.access_time,
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 28),
                        Text('Reach by Platform', style: AppTextStyles.headlineSmall(AppColors.textPrimary)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: _ReachByPlatformChart(
                            reachByPlatform:
                                (_summary?['reachByPlatform'] as Map?)?.cast<String, dynamic>() ?? {},
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReachByPlatformChart extends StatelessWidget {
  const _ReachByPlatformChart({required this.reachByPlatform});

  final Map<String, dynamic> reachByPlatform;

  @override
  Widget build(BuildContext context) {
    if (reachByPlatform.isEmpty) {
      return Center(
        child: Text('No analytics data yet.', style: AppTextStyles.bodyMedium(AppColors.textMuted)),
      );
    }

    final platforms = reachByPlatform.keys.toList();
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= platforms.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(platforms[index], style: AppTextStyles.bodySmall(AppColors.textSecondary)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < platforms.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: (reachByPlatform[platforms[i]] as num).toDouble(),
                color: AppColors.flacronRed,
                width: 28,
                borderRadius: BorderRadius.circular(6),
              ),
            ]),
        ],
      ),
    );
  }
}
