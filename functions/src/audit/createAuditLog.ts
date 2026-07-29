import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { writeAuditLog, extractRequestMeta } from "../utils/auditLog";
import { env } from "../config/env";

const InputSchema = z.object({
  action: z.string().min(1),
  resourceType: z.string().min(1),
  resourceId: z.string().optional(),
});

/**
 * createAuditLog — HTTPS Callable.
 * Most audit entries are written internally by other backend functions
 * (see utils/auditLog.ts), but this callable exists so the Flutter
 * frontend can log client-observable sensitive actions too — e.g. a user
 * viewing/exporting a white-label report, or an admin-panel action taken
 * from the web admin UI (PDF Section 29: Security Requirements — Audit Logs).
 */
export const createAuditLog = onCall(
  { region: env.functionsRegion, timeoutSeconds: 10 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await writeAuditLog({
      userId: uid,
      ...input,
      ...extractRequestMeta(request),
    });

    return { success: true };
  }
);
