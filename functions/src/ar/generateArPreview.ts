import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requirePlanFeature } from "../middleware/planGuard";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";

const InputSchema = z.object({
  arCampaignId: z.string().min(1),
});

/**
 * generateArPreview — HTTPS Callable (PDF Section 17: AR Technical Direction).
 *
 * MVP approach: generate a realistic "composited scene" preview (e.g. the
 * user's flyer/product image placed into a storefront/salon-mirror/table
 * scene) as a static image or a WebAR/WebXR-ready 3D scene descriptor,
 * rather than true device AR. This keeps the feature shippable on Flutter
 * Web immediately while staying architecturally compatible with true
 * ARCore/ARKit mobile AR later (Phase 2, PDF Section 17 "AR Technical
 * Direction — For Mobile Future").
 *
 * TODO real implementation options (pick one for production):
 *   1. Server-side image compositing (e.g. sharp/Jimp) laying the source
 *      image onto a scene template (storefront.png, salon_mirror.png, etc.)
 *      stored in Cloud Storage, uploading the composited result back to
 *      Storage and saving its public URL as generatedPreviewUrl.
 *   2. A Three.js/Babylon.js scene JSON descriptor that the Flutter Web
 *      frontend renders client-side using WebGL, with sourceMediaUrl as a
 *      texture — in that case generatedPreviewUrl would point to a JSON
 *      scene config document instead of a rendered image.
 */
export const generateArPreview = onCall(
  { region: env.functionsRegion, timeoutSeconds: 60, memory: "512MiB" },
  async (request) => {
    const uid = requireAuth(request);
    const { arCampaignId } = InputSchema.parse(request.data);

    await requirePlanFeature(uid, "arAccess");

    const ref = db.doc(`users/${uid}/arCampaigns/${arCampaignId}`);
    const snap = await ref.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "AR campaign not found.");
    }

    // Placeholder: in production this calls the compositing/rendering
    // pipeline described above. For now we mark it processed and echo back
    // the source media as a "preview" so the frontend flow is fully testable.
    const campaign = snap.data() as { sourceMediaUrl: string };
    const generatedPreviewUrl = campaign.sourceMediaUrl; // TODO: replace with real composited output

    await ref.update({
      generatedPreviewUrl,
      status: "ready",
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { arCampaignId, generatedPreviewUrl, status: "ready" };
  }
);
