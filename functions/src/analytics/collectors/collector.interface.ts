export interface InsightMetrics {
  impressions: number;
  reach: number;
  likes: number;
  comments: number;
  shares: number;
  saves: number;
  clicks: number;
}

export interface InsightCollector {
  readonly platform: "instagram" | "facebook" | "twitter" | "linkedin";
  fetchInsights(accessTokenPlain: string, externalPostId: string): Promise<InsightMetrics>;
}
