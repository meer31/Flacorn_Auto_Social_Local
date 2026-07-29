import { SocialPublisher } from "./publisher.interface";
import { MetaPublisher } from "./metaPublisher";
import { TwitterPublisher } from "./twitterPublisher";
import { LinkedInPublisher } from "./linkedinPublisher";

export function getPublisher(
  platform: "instagram" | "facebook" | "twitter" | "linkedin"
): SocialPublisher {
  switch (platform) {
    case "instagram":
      return new MetaPublisher("instagram");
    case "facebook":
      return new MetaPublisher("facebook");
    case "twitter":
      return new TwitterPublisher();
    case "linkedin":
      return new LinkedInPublisher();
    default:
      throw new Error(`No publisher configured for platform: ${platform}`);
  }
}
