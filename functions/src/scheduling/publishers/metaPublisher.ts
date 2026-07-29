import { PublishInput, PublishResult, SocialPublisher } from "./publisher.interface";

/**
 * Publishes to Instagram Business / Facebook Pages via the Meta Graph API.
 * TODO: implement real calls to:
 *   POST /{page-id}/photos or /{ig-user-id}/media + /media_publish
 * using input.accessTokenPlain. Kept as a clearly-marked placeholder so the
 * worker's retry/status/error-handling logic can be fully exercised in the
 * emulator before real Meta app review/approval is complete.
 */
export class MetaPublisher implements SocialPublisher {
  readonly platform: "instagram" | "facebook";

  constructor(platform: "instagram" | "facebook") {
    this.platform = platform;
  }

  async publish(input: PublishInput): Promise<PublishResult> {
    void input;
    throw new Error(`MetaPublisher.publish() not yet implemented for ${this.platform}.`);
  }
}
