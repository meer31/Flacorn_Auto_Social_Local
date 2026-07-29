import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requireWithinUsageLimit } from "../middleware/planGuard";
import { env } from "../config/env";

const InputSchema = z.object({
  platform: z.enum(["meta", "twitter", "linkedin"]),
});

/**
 * getOAuthUrl — HTTPS Callable (PDF Section 10: Social Media Account Connections).
 *
 * Builds the platform-specific OAuth authorization URL. The `state` param
 * carries the Firebase uid (signed/opaque in production — for MVP we embed
 * it directly and validate ownership again in oauthCallback) so the
 * callback can attribute the resulting tokens to the right user.
 *
 * TODO: replace the `state` scheme with a signed, single-use token stored
 * in Firestore (`oauthStates/{state}` with a short TTL) before production,
 * to prevent state-parameter tampering/replay.
 */
export const getOAuthUrl = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const uid = requireAuth(request);
    const { platform } = InputSchema.parse(request.data);

    // Enforce social account connection limit before starting the OAuth dance.
    await requireWithinUsageLimit(uid, "socialAccountLimit", "socialAccountsUsed");

    const state = Buffer.from(JSON.stringify({ uid, platform, ts: Date.now() })).toString(
      "base64url"
    );

    let url: string;
    switch (platform) {
      case "meta": {
        const params = new URLSearchParams({
          client_id: env.social.meta.appId,
          redirect_uri: env.social.meta.redirectUri,
          scope: "pages_show_list,pages_manage_posts,instagram_basic,instagram_content_publish",
          response_type: "code",
          state,
        });
        url = `https://www.facebook.com/v19.0/dialog/oauth?${params.toString()}`;
        break;
      }
      case "twitter": {
        const params = new URLSearchParams({
          client_id: env.social.twitter.clientId,
          redirect_uri: env.social.twitter.redirectUri,
          scope: "tweet.read tweet.write users.read offline.access",
          response_type: "code",
          state,
          code_challenge: "challenge", // TODO: implement PKCE properly
          code_challenge_method: "plain",
        });
        url = `https://twitter.com/i/oauth2/authorize?${params.toString()}`;
        break;
      }
      case "linkedin": {
        const params = new URLSearchParams({
          client_id: env.social.linkedin.clientId,
          redirect_uri: env.social.linkedin.redirectUri,
          scope: "w_member_social r_liteprofile r_organization_social",
          response_type: "code",
          state,
        });
        url = `https://www.linkedin.com/oauth/v2/authorization?${params.toString()}`;
        break;
      }
      default:
        throw new HttpsError("invalid-argument", "Unsupported platform.");
    }

    return { url, state };
  }
);
