import { db, FieldValue } from "../config/firebase";
import { CallableRequest } from "firebase-functions/v2/https";

export interface AuditLogEntry {
  userId: string;
  action: string;
  resourceType: string;
  resourceId?: string;
  ipAddress?: string;
  userAgent?: string;
}

/**
 * Writes an entry to the top-level `auditLogs` collection.
 * Called from sensitive operations: plan changes, disconnects, admin
 * actions, billing events, token refresh failures, etc.
 */
export async function writeAuditLog(entry: AuditLogEntry): Promise<void> {
  await db.collection("auditLogs").add({
    ...entry,
    createdAt: FieldValue.serverTimestamp(),
  });
}

/** Best-effort extraction of IP/user-agent from a callable request's rawRequest. */
export function extractRequestMeta(request: CallableRequest): {
  ipAddress?: string;
  userAgent?: string;
} {
  const raw = request.rawRequest;
  return {
    ipAddress: (raw?.headers?.["x-forwarded-for"] as string) ?? raw?.ip,
    userAgent: raw?.headers?.["user-agent"] as string | undefined,
  };
}
