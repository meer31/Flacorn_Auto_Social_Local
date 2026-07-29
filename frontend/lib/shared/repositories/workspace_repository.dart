import '../../core/services/firebase_service.dart';
import '../../core/services/functions_service.dart';
import '../models/workspace.dart';

class WorkspaceRepository {
  WorkspaceRepository({FirebaseService? firebaseService, FunctionsService? functionsService})
      : _firebase = firebaseService ?? FirebaseService.instance,
        _functions = functionsService ?? FunctionsService.instance;

  final FirebaseService _firebase;
  final FunctionsService _functions;

  Future<Workspace?> getWorkspace(String workspaceId) async {
    final doc = await _firebase.workspaceDoc(workspaceId).get();
    if (!doc.exists) return null;
    return Workspace.fromMap(doc.id, doc.data()!);
  }

  Stream<Workspace?> watchWorkspace(String workspaceId) {
    return _firebase.workspaceDoc(workspaceId).snapshots().map(
          (doc) => doc.exists ? Workspace.fromMap(doc.id, doc.data()!) : null,
        );
  }

  Stream<List<WorkspaceMember>> watchMembers(String workspaceId) {
    return _firebase.workspaceSubcollection(workspaceId, 'members').snapshots().map(
          (snap) => snap.docs.map((d) => WorkspaceMember.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<WorkspaceMember?> getMyMembership(String workspaceId, String uid) async {
    final doc = await _firebase.workspaceSubcollection(workspaceId, 'members').doc(uid).get();
    if (!doc.exists) return null;
    return WorkspaceMember.fromMap(doc.id, doc.data()!);
  }

  Stream<List<ApprovalRequest>> watchPendingApprovals(String workspaceId) {
    return _firebase
        .workspaceSubcollection(workspaceId, 'approvals')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((d) => ApprovalRequest.fromMap(d.id, d.data())).toList());
  }

  // ---- Writes go through Cloud Functions — role checks and audit logging
  // happen server-side, never trust the client for anything that changes
  // who-can-do-what. ----

  Future<void> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
  }) {
    return _functions.inviteMember({
      'workspaceId': workspaceId,
      'email': email,
      'role': role,
    });
  }

  Future<void> acceptInvite(String inviteId) {
    return _functions.acceptInvite({'inviteId': inviteId});
  }

  Future<void> updateMemberRole({
    required String workspaceId,
    required String memberUid,
    required String role,
  }) {
    return _functions.updateMemberRole({
      'workspaceId': workspaceId,
      'memberUid': memberUid,
      'role': role,
    });
  }

  Future<void> removeMember({required String workspaceId, required String memberUid}) {
    return _functions.removeMember({
      'workspaceId': workspaceId,
      'memberUid': memberUid,
    });
  }

  Future<void> requestApproval({required String workspaceId, required String scheduledPostId}) {
    return _functions.requestApproval({
      'workspaceId': workspaceId,
      'scheduledPostId': scheduledPostId,
    });
  }

  Future<void> decideApproval({
    required String workspaceId,
    required String approvalId,
    required bool approve,
    String? note,
  }) {
    return _functions.decideApproval({
      'workspaceId': workspaceId,
      'approvalId': approvalId,
      'approve': approve,
      'note': note,
    });
  }
}
