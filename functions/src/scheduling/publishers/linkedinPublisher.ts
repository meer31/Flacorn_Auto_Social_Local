import { PublishInput, PublishResult, SocialPublisher } from "./publisher.interface";

/**
 * Publishes to LinkedIn (personal profile or organization page).
 * TODO: implement POST https://api.linkedin.com/v2/ugcPosts using
 * input.accessTokenPlain and input.accountIdFromPlatform as the author URN.
 */
export class LinkedInPublisher implements SocialPublisher {
  readonly platform = "linkedin" as const;

  async publish(input: PublishInput): Promise<PublishResult> {
    void input;
    throw new Error("LinkedInPublisher.publish() not yet implemented.");
  }
}
