import { PublishInput, PublishResult, SocialPublisher } from "./publisher.interface";

/**
 * Publishes to X/Twitter via API v2.
 * TODO: implement POST https://api.twitter.com/2/tweets with OAuth2 bearer
 * token from input.accessTokenPlain, and media upload via v1.1 media/upload
 * endpoint if input.mediaUrl is present.
 */
export class TwitterPublisher implements SocialPublisher {
  readonly platform = "twitter" as const;

  async publish(input: PublishInput): Promise<PublishResult> {
    void input;
    throw new Error("TwitterPublisher.publish() not yet implemented.");
  }
}
