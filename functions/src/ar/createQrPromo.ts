import { onCall, HttpsError } from "firebase-functions/v2/https";
import { z } from "zod";
import QRCode from "qrcode";
import { requireAuth } from "../middleware/authGuard";
import { requirePlanFeature } from "../middleware/planGuard";
import { db, storage, FieldValue } from "../config/firebase";
import { env } from "../config/env";

const InputSchema = z.object({
  arCampaignId: z.string().min(1),
  destinationUrl: z.string().url(), // landing page: business intro, logo, services, links, booking button
});

/**
 * createQrPromo — HTTPS Callable (PDF Section 17: AR Feature 3 — AR Business
 * Card / QR Promo). Generates a scannable QR code PNG pointing at a
 * business's promo landing page, uploads it to Cloud Storage, and links it
 * to the AR campaign.
 *
 * The landing page itself (business intro/logo/services/social links/
 * booking button) is a Phase 2 hosted micro-page — see docs/AR_ROADMAP.md.
 * For MVP, `destinationUrl` can point at an existing external booking page
 * or a simple hosted profile page.
 */
export const createQrPromo = onCall(
  { region: env.functionsRegion, timeoutSeconds: 30 },
  async (request) => {
    const uid = requireAuth(request);
    const { arCampaignId, destinationUrl } = InputSchema.parse(request.data);

    await requirePlanFeature(uid, "arCampaignBuilder");

    const campaignRef = db.doc(`users/${uid}/arCampaigns/${arCampaignId}`);
    const snap = await campaignRef.get();
    if (!snap.exists) {
      throw new HttpsError("not-found", "AR campaign not found.");
    }

    const qrBuffer = await QRCode.toBuffer(destinationUrl, { width: 512, margin: 2 });

    const filePath = `users/${uid}/ar/${arCampaignId}-qr.png`;
    const file = storage.bucket(env.firebase.storageBucket).file(filePath);
    await file.save(qrBuffer, { contentType: "image/png", public: false });

    // Generate a signed URL valid for 7 days; refresh via a future callable
    // if longer-lived public access is needed (or make the bucket path public).
    const [qrCodeUrl] = await file.getSignedUrl({
      action: "read",
      expires: Date.now() + 7 * 24 * 60 * 60 * 1000,
    });

    await campaignRef.update({
      qrCodeUrl,
      status: "ready",
      updatedAt: FieldValue.serverTimestamp(),
    });

    return { arCampaignId, qrCodeUrl };
  }
);
