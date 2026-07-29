import { onCall } from "firebase-functions/v2/https";
import { z } from "zod";
import { requireAuth } from "../middleware/authGuard";
import { requirePlanFeature } from "../middleware/planGuard";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";

const AR_TYPES = [
  "promo_preview", // AR Feature 1: storefront, salon mirror, office wall, etc.
  "product_showcase", // AR Feature 2: product/book/shirt/flyer/logo 3D preview
  "qr_promo", // AR Feature 3: AR business card / QR promo
  "before_and_after", // AR Feature 4: split-screen transformation content
] as const;

const InputSchema = z.object({
  campaignName: z.string().min(1),
  arType: z.enum(AR_TYPES),
  sourceMediaUrl: z.string().url(),
  previewScene: z.string().optional(), // e.g. "storefront", "salon_mirror", "restaurant_table"
  linkedPostRef: z.string().optional(),
});

/**
 * createArCampaign — HTTPS Callable (PDF Section 17: AR Features).
 * Gated behind `arAccess` (Pro: basic preview, limited campaigns;
 * Agency/Enterprise: full AR campaign builder — enforce campaign COUNT
 * limits for Pro at the frontend/dashboard level, see docs/AR_ROADMAP.md).
 */
export const createArCampaign = onCall(
  { region: env.functionsRegion, timeoutSeconds: 30 },
  async (request) => {
    const uid = requireAuth(request);
    const input = InputSchema.parse(request.data);

    await requirePlanFeature(uid, "arAccess");

    const ref = db.collection(`users/${uid}/arCampaigns`).doc();
    await ref.set({
      campaignName: input.campaignName,
      arType: input.arType,
      sourceMediaUrl: input.sourceMediaUrl,
      previewScene: input.previewScene ?? null,
      generatedPreviewUrl: null, // populated by generateArPreview
      qrCodeUrl: null, // populated by createQrPromo, if arType === "qr_promo"
      linkedPostRef: input.linkedPostRef ?? null,
      status: "processing",
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { arCampaignId: ref.id };
  }
);
