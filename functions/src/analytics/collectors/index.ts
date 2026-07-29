import { InsightCollector } from "./collector.interface";
import { MetaInsightCollector } from "./metaInsightCollector";
import { TwitterInsightCollector } from "./twitterInsightCollector";
import { LinkedInInsightCollector } from "./linkedinInsightCollector";

export function getInsightCollector(
  platform: "instagram" | "facebook" | "twitter" | "linkedin"
): InsightCollector {
  switch (platform) {
    case "instagram":
      return new MetaInsightCollector("instagram");
    case "facebook":
      return new MetaInsightCollector("facebook");
    case "twitter":
      return new TwitterInsightCollector();
    case "linkedin":
      return new LinkedInInsightCollector();
    default:
      throw new Error(`No insight collector configured for platform: ${platform}`);
  }
}
