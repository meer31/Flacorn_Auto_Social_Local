import { InsightCollector, InsightMetrics } from "./collector.interface";

/**
 * TODO: implement GET /v2/organizationalEntityShareStatistics (org pages)
 * or /v2/socialActions/{shareUrn} (personal posts) via the LinkedIn API.
 */
export class LinkedInInsightCollector implements InsightCollector {
  readonly platform = "linkedin" as const;

  async fetchInsights(accessTokenPlain: string, externalPostId: string): Promise<InsightMetrics> {
    void accessTokenPlain;
    void externalPostId;
    throw new Error("LinkedInInsightCollector.fetchInsights() not yet implemented.");
  }
}
