import { InsightMetrics } from "./collectors/collector.interface";

/**
 * calculateEngagementRate — shared utility (also usable as an internal
 * helper elsewhere in analytics/*).
 *
 * Standard formula: (likes + comments + shares + saves) / reach, expressed
 * as a percentage. Falls back to impressions if reach is unavailable
 * (some platforms only report impressions for certain post types).
 */
export function calculateEngagementRate(metrics: InsightMetrics): number {
  const engagementActions = metrics.likes + metrics.comments + metrics.shares + metrics.saves;
  const denominator = metrics.reach > 0 ? metrics.reach : metrics.impressions;

  if (!denominator || denominator <= 0) return 0;

  return Number(((engagementActions / denominator) * 100).toFixed(2));
}
