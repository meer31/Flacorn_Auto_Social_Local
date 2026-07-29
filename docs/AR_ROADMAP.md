# AR Feature Roadmap

## MVP Scope (Implemented Architecture)
Per PDF Section 17, the MVP ships a **realistic web-based visual preview
system**, not true device AR. This is fully wired end-to-end:

- `createArCampaign` — creates an `arCampaigns/{id}` record for one of
  four types: `promo_preview`, `product_showcase`, `qr_promo`,
  `before_and_after`.
- `generateArPreview` — produces the composited preview. **Currently a
  placeholder** that echoes the source image back as `generatedPreviewUrl`
  — see the TODO block in `functions/src/ar/generateArPreview.ts` for the
  two production implementation paths (server-side image compositing vs.
  a Three.js/Babylon.js scene descriptor rendered client-side).
- `createQrPromo` — fully implemented: generates a real scannable QR
  code PNG via the `qrcode` npm package, uploads it to Cloud Storage, and
  links it to the campaign.
- Frontend: `features/ar_campaigns/screens/ar_campaigns_screen.dart`
  lets users pick an AR type + scene, supply a source image URL (from the
  Media Library), and view the generated preview grid.

## Plan Gating
| Plan | AR Access |
|---|---|
| Starter | None |
| Pro | Basic AR post preview, limited campaigns |
| Agency | Full AR campaign builder, AR QR promo, client AR campaigns |
| Enterprise | Custom AR branding, custom templates, white-label AR |

Enforced via the `arAccess` / `arCampaignBuilder` flags in
`config/plans.ts` + `middleware/planGuard.ts`.

## Phase 2: True AR
- **Web**: Three.js or Babylon.js WebXR scene, letting the browser use
  the device camera (where supported) to place the promo image in the
  real environment, not just a static composited photo.
- **Mobile**: ARCore (Android) / ARKit (iOS) via a Flutter AR plugin —
  the PDF explicitly recommends NOT depending on a single unstable
  Flutter AR package long-term, and considering Unity AR Foundation for
  advanced 3D needs.
- **AR Business Card / QR Promo landing page**: a hosted micro-page
  (business intro, logo, services, social links, booking button) that
  the QR code points to — currently `createQrPromo` accepts any
  `destinationUrl`, so this can point at an external page today and a
  purpose-built hosted page in Phase 2.

## Recommended Next Steps for a Developer Picking This Up
1. Decide compositing approach (server image processing vs. client-side
   3D scene) based on desired visual quality vs. engineering effort.
2. If server-side: add `sharp` or `Jimp` to `functions/package.json`,
   store scene template images (storefront.png, salon_mirror.png, etc.)
   in Cloud Storage, and implement the compositing logic in
   `generateArPreview.ts`.
3. If client-side: define a JSON scene-descriptor schema, generate it in
   `generateArPreview.ts`, and build a `three_js`-based Flutter Web
   widget (via an embedded WebView or `js_interop`) to render it.
4. Build the AR Business Card landing page as a lightweight public route
   (no auth) reading from `arCampaigns/{id}` by a public-safe subset of
   fields.
