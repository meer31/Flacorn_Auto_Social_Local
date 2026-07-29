import { db, FieldValue } from "../config/firebase";

export type NotificationType =
  | "reconnect_required"
  | "post_published"
  | "post_failed"
  | "usage_limit_reached"
  | "upgrade_suggestion"
  | "weekly_report_ready"
  | "top_post_highlight"
  | "approval_requested"
  | "approval_decided"
  | "member_invited"
  | "member_joined";

export interface CreateNotificationInput {
  workspaceId: string;
  /** If set, only this member sees it (e.g. "your post was approved").
   * If omitted, every member of the workspace sees it (e.g. "Instagram
   * needs reconnecting" — everyone with access should know). */
  targetUid?: string;
  type: NotificationType;
  title: string;
  message: string;
  actionRoute?: string; // deep link within the Flutter app, e.g. "/connected-accounts"
}

/**
 * createNotification — Internal helper (not a public callable).
 * Called from other backend modules (runScheduledPosts, checkPlanAccess
 * flows, refreshTokenIfNeeded, generateWeeklyReport, workspace approval
 * flows) to populate the Smart Alerts feed described in PDF Section 23
 * (Dashboard Requirements).
 *
 * MIGRATION NOTE (Team/RBAC): notifications moved from
 * users/{userId}/notifications to workspaces/{workspaceId}/notifications
 * so a teammate's actions (e.g. requesting approval) can notify the right
 * people in a shared workspace, not just the acting user themselves.
 *
 * Examples this powers:
 *   "You have no posts scheduled this week."
 *   "Your Instagram account needs reconnecting."
 *   "Your top post this month was about promotions."
 *   "Upgrade to Pro to unlock unlimited scheduling."
 *   "Sarah requested approval for a post." (targetUid = each admin/owner)
 */
export async function createNotification(input: CreateNotificationInput): Promise<string> {
  const ref = db.collection(`workspaces/${input.workspaceId}/notifications`).doc();
  await ref.set({
    targetUid: input.targetUid ?? null,
    type: input.type,
    title: input.title,
    message: input.message,
    actionRoute: input.actionRoute ?? null,
    read: false,
    readAt: null,
    createdAt: FieldValue.serverTimestamp(),
  });
  return ref.id;
}
