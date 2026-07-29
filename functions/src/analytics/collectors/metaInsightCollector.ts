import { InsightCollector, InsightMetrics } from "./collector.interface";

/**
 * TODO: implement GET /{media-id}/insights (Instagram) or
 * /{post-id}/insights (Facebook Page) via the Meta Graph API, mapping
 * their metric names (impressions, reach, engagement, saved, etc.) onto
 * our normalized InsightMetrics shape.
 */
export class MetaInsightCollector implements InsightCollector {
  readonly platform: "instagram" | "facebook";

  constructor(platform: "instagram" | "facebook") {
    this.platform = platform;
  }

  async fetchInsights(accessTokenPlain: string, externalPostId: string): Promise<InsightMetrics> {
    void accessTokenPlain;
    void externalPostId;
    throw new Error(`MetaInsightCollector.fetchInsights() not yet implemented for ${this.platform}.`);
  }
}
