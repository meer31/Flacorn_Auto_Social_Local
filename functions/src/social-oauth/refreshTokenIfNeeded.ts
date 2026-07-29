import { db, FieldValue } from "../config/firebase";
import { decryptToken, encryptToken } from "../utils/encryption";
import { writeAuditLog } from "../utils/auditLog";

interface RefreshResult {
  accessToken: string;
  refreshToken?: string;
  expiresInSeconds: number;
}

/**
 * Platform-specific refresh call. TODO: implement real refresh-token
 * exchanges for Meta (long-lived token refresh), X/Twitter (OAuth2 refresh
 * grant), and LinkedIn (refresh token grant) once app credentials exist.
 */
async function refreshWithPlatform(
  platform: string,
  refreshTokenPlain: string
): Promise<RefreshResult> {
  void refreshTokenPlain;
  throw new Error(`Token refresh not yet implemented for platform: ${platform}`);
}

/**
 * refreshTokenIfNeeded — Internal helper (also exposed as a callable below).
 * Called from runScheduledPosts before publishing, and can be invoked
 * directly by the frontend when a "Reconnect required" banner is dismissed
 * after the user re-authenticates.
 *
 * PDF Section 10: "If token expires, backend should refresh it automatically
 * where supported. If refresh fails, frontend should show 'Reconnect required.'"
 */
export async function refreshTokenIfNeededInternal(
  userId: string,
  socialAccountId: string
): Promise<{ refreshed: boolean; needsReconnect: boolean }> {
  const ref = db.doc(`users/${userId}/socialAccounts/${socialAccountId}`);
  const snap = await ref.get();
  if (!snap.exists) {
    return { refreshed: false, needsReconnect: true };
  }

  const data = snap.data() as {
    platform: string;
    refreshTokenEncrypted?: string | null;
    tokenExpiry?: string | null;
  };

  const expiresSoon =
    !data.tokenExpiry || new Date(data.tokenExpiry).getTime() - Date.now() < 10 * 60 * 1000;

  if (!expiresSoon) {
    return { refreshed: false, needsReconnect: false };
  }

  if (!data.refreshTokenEncrypted) {
    await ref.update({ connectionStatus: "needs_reconnect", updatedAt: FieldValue.serverTimestamp() });
    return { refreshed: false, needsReconnect: true };
  }

  try {
    const refreshTokenPlain = decryptToken(data.refreshTokenEncrypted);
    const result = await refreshWithPlatform(data.platform, refreshTokenPlain);

    await ref.update({
      accessTokenEncrypted: encryptToken(result.accessToken),
      refreshTokenEncrypted: result.refreshToken ? encryptToken(result.refreshToken) : data.refreshTokenEncrypted,
      tokenExpiry: new Date(Date.now() + result.expiresInSeconds * 1000).toISOString(),
      connectionStatus: "connected",
      lastRefreshedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { refreshed: true, needsReconnect: false };
  } catch (err) {
    console.error(`refreshTokenIfNeeded: failed for ${userId}/${socialAccountId}`, err);
    await ref.update({ connectionStatus: "needs_reconnect", updatedAt: FieldValue.serverTimestamp() });
    await writeAuditLog({
      userId,
      action: "social_account.refresh_failed",
      resourceType: "socialAccount",
      resourceId: socialAccountId,
    });
    return { refreshed: false, needsReconnect: true };
  }
}
