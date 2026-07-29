import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Small metric card used across the Dashboard and Analytics screens
/// (PDF Section 23: Dashboard Requirements — Performance cards).
class StatCard extends StatelessWidget {
  const StatCard({
    required this.label,
    required this.value,
    this.icon,
    this.trend,
    this.trendIsPositive = true,
    this.accentColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final String? trend;
  final bool trendIsPositive;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.flacronRed;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodySmall(AppColors.textSecondary)),
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: accent),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.headlineSmall(AppColors.textPrimary)),
          if (trend != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  trendIsPositive ? Icons.trending_up : Icons.trending_down,
                  size: 14,
                  color: trendIsPositive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: AppTextStyles.bodySmall(
                    trendIsPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
