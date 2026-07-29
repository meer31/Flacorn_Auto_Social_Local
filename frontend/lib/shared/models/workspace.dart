/// Mirrors Firestore path: workspaces/{workspaceId}
///
/// The workspace is the tenant that owns everything — social accounts,
/// scheduled posts, campaigns, media, templates, etc. A user always has
/// at least one (created automatically on signup, see
/// functions/src/user/onUserCreate.ts) and may belong to more than one
/// if invited as a teammate elsewhere.
class Workspace {
  final String id;
  final String name;
  final String ownerUid;
  final String businessCategory;
  final DateTime createdAt;

  const Workspace({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.businessCategory,
    required this.createdAt,
  });

  factory Workspace.fromMap(String id, Map<String, dynamic> map) {
    return Workspace(
      id: id,
      name: map['name'] as String? ?? '',
      ownerUid: map['ownerUid'] as String? ?? '',
      businessCategory: map['businessCategory'] as String? ?? '',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : (map['createdAt']?.toDate() ?? DateTime.now()),
    );
  }
}

/// Mirrors Firestore path: workspaces/{workspaceId}/members/{uid}
///
/// role is one of: owner | admin | editor | viewer.
///   owner  — full control, only role that can delete the workspace or
///            remove the last owner.
///   admin  — invite/remove members (except owner), manage billing.
///   editor — create/schedule posts, campaigns; publishing requires
///            approval unless the workspace has approval disabled.
///   viewer — read-only, analytics access.
class WorkspaceMember {
  final String uid;
  final String role;
  final String? invitedBy;
  final DateTime joinedAt;

  const WorkspaceMember({
    required this.uid,
    required this.role,
    this.invitedBy,
    required this.joinedAt,
  });

  factory WorkspaceMember.fromMap(String uid, Map<String, dynamic> map) {
    return WorkspaceMember(
      uid: uid,
      role: map['role'] as String? ?? 'viewer',
      invitedBy: map['invitedBy'] as String?,
      joinedAt: map['joinedAt'] is DateTime
          ? map['joinedAt'] as DateTime
          : (map['joinedAt']?.toDate() ?? DateTime.now()),
    );
  }

  bool get canManageMembers => role == 'owner' || role == 'admin';
  bool get canApprove => role == 'owner' || role == 'admin';
  bool get canCreateContent => role != 'viewer';
  bool get canPublishDirectly => role == 'owner' || role == 'admin';
}

/// Mirrors Firestore path: workspaces/{workspaceId}/approvals/{approvalId}
class ApprovalRequest {
  final String id;
  final String scheduledPostId;
  final String requestedBy;
  final String status; // pending | approved | rejected
  final String? reviewedBy;
  final String? note;
  final DateTime createdAt;

  const ApprovalRequest({
    required this.id,
    required this.scheduledPostId,
    required this.requestedBy,
    required this.status,
    this.reviewedBy,
    this.note,
    required this.createdAt,
  });

  factory ApprovalRequest.fromMap(String id, Map<String, dynamic> map) {
    return ApprovalRequest(
      id: id,
      scheduledPostId: map['scheduledPostId'] as String? ?? '',
      requestedBy: map['requestedBy'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      reviewedBy: map['reviewedBy'] as String?,
      note: map['note'] as String?,
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt'] as DateTime
          : (map['createdAt']?.toDate() ?? DateTime.now()),
    );
  }
}
