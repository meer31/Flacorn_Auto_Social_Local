import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { db } from "../config/firebase";
import { withUpdateTimestamp } from "../utils/timestamps";
import { env } from "../config/env";

const InputSchema = z.object({
  arCampaignId: z.string().min(1),
  campaignName: z.string().optional(),
  previewScene: z.string().optional(),
  linkedPostRef: z.string().optional(),
  status: z.enum(["draft", "processing", "ready", "published"]).optional(),
});

/**
 * saveArCampaign — HTTPS Callable (PDF Section 17 / Firestore Section 26).
 * Generic update endpoint for editing AR campaign metadata after creation —
 * e.g. renaming, linking to a scheduled post, or marking it published.
 */
export const saveArCampaign = onCall(
  { region: env.functionsRegion, timeoutSeconds: 15 },
  async (request) => {
    const uid = requireAuth(request);
    const { arCampaignId, ...updates } = InputSchema.parse(request.data);

    const ref = db.doc(`users/${uid}/arCampaigns/${arCampaignId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "AR campaign not found.");
    }

    await ref.update(withUpdateTimestamp(updates));
    return { success: true };
  }
);
