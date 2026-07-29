import { onSchedule } from "firebase-functions/v2/scheduler";
import { requirePlanFeatureForUser } from "../subscriptions/planFeatureHelper";
import { generateJson } from "./aiService";
import { buildWeeklyReportPrompt } from "./promptTemplates";
import { env } from "../config/env";
import { db, FieldValue } from "../config/firebase";

/**
 * generateWeeklyReport — Scheduled Function (PDF Section 16).
 * Runs weekly for all Pro/Agency users, aggregates the past 7 days of
 * postInsights, and writes an AI-generated summary to weeklyReports/.
 * Optionally emails the report (see notifications/emailService — Phase 2).
 *
 * Schedule: every Monday 07:00 in each user's local context is ideal, but
 * for MVP simplicity this runs once daily UTC and is idempotent per ISO week.
 */
export const generateWeeklyReport = onSchedule(
  { schedule: "0 8 * * 1", timeZone: "UTC", region: env.functionsRegion, timeoutSeconds: 540 },
  async () => {
    const usersSnap = await db.collection("users").get();

    for (const userDoc of usersSnap.docs) {
      const uid = userDoc.id;
      const hasAccess = await requirePlanFeatureForUser(uid, "weeklyAiReport");
      if (!hasAccess) continue;

      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const insightsSnap = await db
        .collection(`users/${uid}/postInsights`)
        .where("fetchedAt", ">=", sevenDaysAgo)
        .get();

      if (insightsSnap.empty) continue;

      const insights = insightsSnap.docs.map((d) => d.data());
      const sorted = [...insights].sort(
        (a, b) => (b.engagementRate ?? 0) - (a.engagementRate ?? 0)
      );
      const best = sorted[0];
      const worst = sorted[sorted.length - 1];
      const platformCounts: Record<string, number> = {};
      for (const i of insights) {
        platformCounts[i.platform] = (platformCounts[i.platform] ?? 0) + 1;
      }
      const topPlatform = Object.entries(platformCounts).sort((a, b) => b[1] - a[1])[0]?.[0];

      const userData = userDoc.data();
      const prompt = buildWeeklyReportPrompt({
        postsPublished: insights.length,
        bestPost: best?.externalPostId,
        worstPost: worst?.externalPostId,
        topPlatform,
        businessCategory: userData.businessCategory ?? "general business",
      });

      const aiSummary = await generateJson<{
        suggestedImprovements: string[];
        recommendedNextWeekContent: string[];
        bestCta: string;
        bestContentType: string;
        suggestedPostingFrequency: string;
      }>(prompt);

      await db.collection(`users/${uid}/weeklyReports`).add({
        weekOf: sevenDaysAgo.toISOString(),
        postsPublished: insights.length,
        bestPerformingPost: best ?? null,
        worstPerformingPost: worst ?? null,
        mostEffectivePlatform: topPlatform ?? null,
        ...aiSummary,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      // TODO (Phase 2): send email via notifications/emailService.ts
    }
  }
);
