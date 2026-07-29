import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { db } from "../config/firebase";
import { withUpdateTimestamp } from "../utils/timestamps";
import { env } from "../config/env";

const InputSchema = z.object({
  name: z.string().optional(),
  businessName: z.string().optional(),
  businessCategory: z.string().optional(),
  timezone: z.string().optional(),
  mainGoal: z.string().optional(),
  brandTone: z.string().optional(),
  website: z.string().optional(),
  phoneNumber: z.string().optional(),
  city: z.string().optional(),
});

/**
 * updateUserProfile — HTTPS Callable (PDF Section 8: Onboarding Flow).
 * Called from each onboarding step to progressively fill in the user's
 * profile fields. Intentionally accepts a partial payload so the frontend
 * can call it once per onboarding step.
 */
export const updateUserProfile = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await db.doc(`users/${uid}`).set(withUpdateTimestamp(input), { merge: true });

    return { success: true };
  }
);
