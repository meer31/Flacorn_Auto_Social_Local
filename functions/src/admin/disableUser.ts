import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAdmin } from "../middleware/authGuard";
import { auth } from "../config/firebase";
import { writeAuditLog, extractRequestMeta } from "../utils/auditLog";
import { env } from "../config/env";

const InputSchema = z.object({
  userId: z.string().min(1),
  disabled: z.boolean().default(true),
});

/**
 * disableUser — HTTPS Callable, admin-only (PDF Section 30: Admin Panel —
 * "Disable user"). Uses the Firebase Auth Admin SDK to disable/re-enable
 * sign-in for the target account.
 */
export const disableUser = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const adminUid = requireAdmin(request);
    const { userId, disabled } = InputSchema.parse(request.data);

    await auth.updateUser(userId, { disabled });

    await writeAuditLog({
      userId: adminUid,
      action: disabled ? "admin.user_disabled" : "admin.user_enabled",
      resourceType: "user",
      resourceId: userId,
      ...extractRequestMeta(request),
    });

    return { success: true };
  }
);
