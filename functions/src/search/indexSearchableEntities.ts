import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { db, FieldValue } from "../config/firebase";
import { env } from "../config/env";

/**
 * search/indexSearchableEntities.ts — Firestore Triggers.
 *
 * Keeps workspaces/{workspaceId}/searchIndex/{indexId} in sync whenever a scheduled
 * post, campaign, media item, or template is created/updated/deleted, so
 * the Global Search screen (frontend/lib/features/global_search/) only
 * ever needs a simple read — no client-side aggregation across four
 * different collections.
 *
 * indexId == the source document's own ID, prefixed by type, so each
 * source document maps to exactly one index entry and deletes cleanly:
 *   scheduledPost_{postId}, campaign_{campaignId}, media_{mediaId},
 *   template_{templateId}
 */

async function upsertIndexEntry(
  workspaceId: string,
  indexId: string,
  entry: {
    type: string;
    title: string;
    subtitle?: string;
    thumbnailUrl?: string;
    refPath: string;
  }
): Promise<void> {
  await db.doc(`workspaces/${workspaceId}/searchIndex/${indexId}`).set(
    {
      ...entry,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true }
  );
}

async function removeIndexEntry(workspaceId: string, indexId: string): Promise<void> {
  await db.doc(`workspaces/${workspaceId}/searchIndex/${indexId}`).delete();
}

export const onScheduledPostIndexWrite = onDocumentWritten(
  { document: "workspaces/{workspaceId}/scheduledPosts/{postId}", region: env.functionsRegion },
  async (event) => {
    const { workspaceId, postId } = event.params;
    const indexId = `scheduledPost_${postId}`;
    const after = event.data?.after;

    if (!after?.exists) {
      await removeIndexEntry(workspaceId, indexId);
      return;
    }

    const data = after.data() ?? {};
    await upsertIndexEntry(workspaceId, indexId, {
      type: "scheduledPost",
      title: (data.captionText as string | undefined)?.slice(0, 80) || "(no caption)",
      subtitle: data.platform as string | undefined,
      refPath: `workspaces/${workspaceId}/scheduledPosts/${postId}`,
    });
  }
);

export const onCampaignIndexWrite = onDocumentWritten(
  { document: "workspaces/{workspaceId}/campaigns/{campaignId}", region: env.functionsRegion },
  async (event) => {
    const { workspaceId, campaignId } = event.params;
    const indexId = `campaign_${campaignId}`;
    const after = event.data?.after;

    if (!after?.exists) {
      await removeIndexEntry(workspaceId, indexId);
      return;
    }

    const data = after.data() ?? {};
    await upsertIndexEntry(workspaceId, indexId, {
      type: "campaign",
      title: (data.campaignName as string | undefined) || "(untitled campaign)",
      subtitle: data.goal as string | undefined,
      refPath: `workspaces/${workspaceId}/campaigns/${campaignId}`,
    });
  }
);

export const onMediaIndexWrite = onDocumentWritten(
  { document: "workspaces/{workspaceId}/media/{mediaId}", region: env.functionsRegion },
  async (event) => {
    const { workspaceId, mediaId } = event.params;
    const indexId = `media_${mediaId}`;
    const after = event.data?.after;

    if (!after?.exists) {
      await removeIndexEntry(workspaceId, indexId);
      return;
    }

    const data = after.data() ?? {};
    await upsertIndexEntry(workspaceId, indexId, {
      type: "media",
      title: (data.fileName as string | undefined) || "(untitled file)",
      thumbnailUrl: data.url as string | undefined,
      refPath: `workspaces/${workspaceId}/media/${mediaId}`,
    });
  }
);

export const onTemplateIndexWrite = onDocumentWritten(
  { document: "workspaces/{workspaceId}/postTemplates/{templateId}", region: env.functionsRegion },
  async (event) => {
    const { workspaceId, templateId } = event.params;
    const indexId = `template_${templateId}`;
    const after = event.data?.after;

    if (!after?.exists) {
      await removeIndexEntry(workspaceId, indexId);
      return;
    }

    const data = after.data() ?? {};
    await upsertIndexEntry(workspaceId, indexId, {
      type: "template",
      title: (data.title as string | undefined) || "(untitled template)",
      subtitle: data.platform as string | undefined,
      refPath: `workspaces/${workspaceId}/postTemplates/${templateId}`,
    });
  }
);
