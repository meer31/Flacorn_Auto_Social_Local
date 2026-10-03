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
  // FIX 1: Added error state so crashes show a message instead of
  // propagating to the JS interop layer.
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  // FIX 1: Wrapped entire load in try/catch.
  // The original had no error handling — any failure (function not deployed,
  // network issue, auth error) hit Firebase's JS interop layer and threw:
  //   jsObject.callAsFunction(null, data)! as JSPromise
  // because the JS Promise was null (failed call). Now it fails gracefully.
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(analyticsRepositoryProvider)
          .getSummary(rangeDays: _rangeDays);
      if (mounted) {
        setState(() {
          _summary = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not load analytics. Please check your '
              'connection and try again.';
        });
      }
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
              Text(
                'Analytics',
                style: AppTextStyles.headlineLarge(AppColors.textPrimary),
              ),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 7, label: Text('7 days')),
                  ButtonSegment(value: 30, label: Text('30 days')),
                ],
                selected: {_rangeDays},
                // FIX 2: Original called _load() immediately after setState,
                // but _rangeDays wasn't updated yet inside _load() because
                // setState is async. Added microtask delay so the new value
                // is flushed before the network call fires.
                onSelectionChanged: (v) async {
                  setState(() => _rangeDays = v.first);
                  await Future.microtask(() {});
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasAdvanced) ...[
            const UpgradePromptBanner(
              message:
                  'Advanced analytics are available on Pro and Agency plans.',
            ),
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
                // FIX 1: Error state is now rendered instead of crashing.
                : _error != null
                    ? _ErrorView(
                        message: _error!,
                        onRetry: _load,
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
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
                                      value:
                                          '${_summary?['totalEngagementActions'] ?? 0}',
                                      icon: Icons.favorite_border,
                                    ),
                                    StatCard(
                                      label: 'Engagement Rate',
                                      value:
                                          '${_summary?['overallEngagementRate'] ?? 0}%',
                                      icon: Icons.percent,
                                    ),
                                    StatCard(
                                      label: 'Best Time (UTC)',
                                      value: _summary?[
                                                  'bestTimeToPostUtcHour'] !=
                                              null
                                          ? '${_summary!['bestTimeToPostUtcHour']}:00'
                                          : '—',
                                      icon: Icons.access_time,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Reach by Platform',
                              style: AppTextStyles.headlineSmall(
                                  AppColors.textPrimary),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child: _ReachByPlatformChart(
                                reachByPlatform:
                                    (_summary?['reachByPlatform'] as Map?)
                                            ?.cast<String, dynamic>() ??
                                        {},
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

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined, size: 56, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium(AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ── Chart ─────────────────────────────────────────────────────────────────────

class _ReachByPlatformChart extends StatelessWidget {
  const _ReachByPlatformChart({required this.reachByPlatform});

  final Map<String, dynamic> reachByPlatform;

  @override
  Widget build(BuildContext context) {
    if (reachByPlatform.isEmpty) {
      return Center(
        child: Text(
          'No analytics data yet.',
          style: AppTextStyles.bodyMedium(AppColors.textMuted),
        ),
      );
    }

    final platforms = reachByPlatform.keys.toList();

    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= platforms.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    platforms[index],
                    style: AppTextStyles.bodySmall(AppColors.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < platforms.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  // FIX 3: Original used (... as num) which crashes if the
                  // backend returns null or a non-numeric value for any
                  // platform. Changed to (... as num?) with a ?? 0 fallback.
                  toY: (reachByPlatform[platforms[i]] as num? ?? 0).toDouble(),
                  color: AppColors.flacronRed,
                  width: 28,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
