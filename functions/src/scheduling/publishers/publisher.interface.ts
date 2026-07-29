/**
 * Common interface every platform publisher adapter must implement.
 * `runScheduledPosts.ts` calls `publisher.publish(...)` without caring
 * which platform it's talking to.
 */
export interface PublishInput {
  accessTokenPlain: string;
  accountIdFromPlatform: string;
  captionText: string;
  hashtags: string[];
  mediaUrl?: string;
}

export interface PublishResult {
  externalPostId: string;
}

export interface SocialPublisher {
  readonly platform: "instagram" | "facebook" | "twitter" | "linkedin";
  publish(input: PublishInput): Promise<PublishResult>;
}
