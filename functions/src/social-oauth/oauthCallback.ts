import { onRequest } from "firebase-functions/v2/https";
import axios from "axios";
import { env } from "../config/env";
import { db, FieldValue } from "../config/firebase";
import { encryptToken } from "../utils/encryption";
import { incrementUsage } from "../subscriptions/incrementUsage";
import { writeAuditLog } from "../utils/auditLog";

interface TokenExchangeResult {
  accessToken: string;
  refreshToken?: string;
  expiresInSeconds?: number;
  accountId: string;
  accountName: string;
}

/**
 * Exchanges an authorization code for tokens with the given platform.
 * TODO: Each branch below is a real integration point — implement against
 * the live Meta Graph API / X API v2 / LinkedIn API token endpoints.
 * Kept as clearly-marked placeholders so the OAuth *flow* (state handling,
 * encryption, Firestore writes, usage counters, audit log) is fully wired
 * and testable even before real API credentials are available.
 */
async function exchangeCodeForToken(
  platform: "meta" | "twitter" | "linkedin",
  code: string
): Promise<TokenExchangeResult> {
  switch (platform) {
    case "meta": {
      // TODO: POST to https://graph.facebook.com/v19.0/oauth/access_token
      // with client_id, client_secret, redirect_uri, code.
      throw new Error("Meta token exchange not yet implemented — see TODO in oauthCallback.ts");
    }
    case "twitter": {
      // TODO: POST to https://api.twitter.com/2/oauth2/token (PKCE flow).
      throw new Error("Twitter token exchange not yet implemented — see TODO in oauthCallback.ts");
    }
    case "linkedin": {
      // TODO: POST to https://www.linkedin.com/oauth/v2/accessToken
      throw new Error("LinkedIn token exchange not yet implemented — see TODO in oauthCallback.ts");
    }
  }
}

/**
 * oauthCallback — HTTPS Request Function (PDF Section 10).
 * Redirect URI target for all three supported platforms (differentiated by
 * ?platform= query param, matching env.social.*.redirectUri values).
 */
export const oauthCallback = onRequest(
  { region: env.functionsRegion, timeoutSeconds: 30 },
  async (req, res) => {
    try {
      const platform = req.query.platform as "meta" | "twitter" | "linkedin" | undefined;
      const code = req.query.code as string | undefined;
      const state = req.query.state as string | undefined;

      if (!platform || !code || !state) {
        res.status(400).send("Missing required OAuth callback parameters.");
        return;
      }

      const decoded = JSON.parse(Buffer.from(state, "base64url").toString("utf-8")) as {
        uid: string;
        platform: string;
      };

      const result = await exchangeCodeForToken(platform, code);

      const accountRef = db.collection(`users/${decoded.uid}/socialAccounts`).doc();
      await accountRef.set({
        platform,
        accountName: result.accountName,
        accountIdFromPlatform: result.accountId,
        accessTokenEncrypted: encryptToken(result.accessToken),
        refreshTokenEncrypted: result.refreshToken ? encryptToken(result.refreshToken) : null,
        tokenExpiry: result.expiresInSeconds
          ? new Date(Date.now() + result.expiresInSeconds * 1000).toISOString()
          : null,
        connectionStatus: "connected",
        lastRefreshedAt: FieldValue.serverTimestamp(),
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      await incrementUsage(decoded.uid, "socialAccountsUsed");
      await writeAuditLog({
        userId: decoded.uid,
        action: "social_account.connected",
        resourceType: "socialAccount",
        resourceId: accountRef.id,
      });

      // Redirect back into the app (deep link / web route that shows success state).
      res.redirect(`${env.appBaseUrl}/connected-accounts?status=success&platform=${platform}`);
    } catch (err) {
      console.error("oauthCallback error", err);
      res.redirect(`${env.appBaseUrl}/connected-accounts?status=error`);
    }
  }
);
