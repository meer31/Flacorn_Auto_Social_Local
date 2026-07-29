import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { db } from "../config/firebase";
import { env } from "../config/env";

const InputSchema = z.object({
  rangeDays: z.union([z.literal(7), z.literal(30)]).default(30),
});

/**
 * generateAnalyticsSummary — HTTPS Callable (PDF Section 15: Analytics Page).
 * Aggregates postInsights into the dashboard-ready shape: reach by platform,
 * engagement summary, top/worst performing posts, and a naive "best time to
 * post" estimate based on historical engagement-by-hour.
 */
export const generateAnalyticsSummary = onCall(
  { region: env.functionsRegion, timeoutSeconds: 30 },
  async (request) => {
    const uid = requireAuth(request);
    const { rangeDays } = InputSchema.parse(request.data ?? {});

    const since = new Date();
    since.setDate(since.getDate() - rangeDays);

    const insightsSnap = await db
      .collection(`users/${uid}/postInsights`)
      .where("fetchedAt", ">=", since)
      .get();

    const insights = insightsSnap.docs.map((d) => d.data());

    const reachByPlatform: Record<string, number> = {};
    let totalEngagementActions = 0;
    let totalReach = 0;

    for (const i of insights) {
      reachByPlatform[i.platform] = (reachByPlatform[i.platform] ?? 0) + (i.reach ?? 0);
      totalReach += i.reach ?? 0;
      totalEngagementActions += (i.likes ?? 0) + (i.comments ?? 0) + (i.shares ?? 0) + (i.saves ?? 0);
    }

    const sorted = [...insights].sort((a, b) => (b.engagementRate ?? 0) - (a.engagementRate ?? 0));
    const topPosts = sorted.slice(0, 5);
    const worstPosts = sorted.slice(-5).reverse();

    // Naive "best time to post": bucket by hour-of-day of fetchedAt of
    // top-quartile-engagement posts. Replace with a proper per-post
    // published-at timestamp analysis once available.
    const hourCounts: Record<number, number> = {};
    for (const p of sorted.slice(0, Math.max(1, Math.ceil(sorted.length / 4)))) {
      const hour = p.fetchedAt?.toDate ? p.fetchedAt.toDate().getUTCHours() : new Date().getUTCHours();
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    const bestHour = Object.entries(hourCounts).sort((a, b) => b[1] - a[1])[0]?.[0];

    return {
      rangeDays,
      totalReach,
      totalEngagementActions,
      overallEngagementRate:
        totalReach > 0 ? Number(((totalEngagementActions / totalReach) * 100).toFixed(2)) : 0,
      reachByPlatform,
      topPosts,
      worstPosts,
      bestTimeToPostUtcHour: bestHour ? Number(bestHour) : null,
      postCount: insights.length,
    };
  }
);
