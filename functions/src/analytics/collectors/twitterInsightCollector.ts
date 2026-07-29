import { InsightCollector, InsightMetrics } from "./collector.interface";

/**
 * TODO: implement GET /2/tweets/:id?tweet.fields=public_metrics via the
 * X API v2, mapping impression_count/like_count/reply_count/retweet_count
 * onto our normalized InsightMetrics shape.
 */
export class TwitterInsightCollector implements InsightCollector {
  readonly platform = "twitter" as const;

  async fetchInsights(accessTokenPlain: string, externalPostId: string): Promise<InsightMetrics> {
    void accessTokenPlain;
    void externalPostId;
    throw new Error("TwitterInsightCollector.fetchInsights() not yet implemented.");
  }
}
