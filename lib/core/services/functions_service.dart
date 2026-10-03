import 'package:cloud_functions/cloud_functions.dart';
import 'package:flacron_auto_social/core/demo/demo_config.dart';
import 'package:flacron_auto_social/core/services/mock_functions_service.dart';

/// Thin wrapper around Firebase Cloud Functions callable invocations.
///
/// SECURITY: This is the ONLY way the Flutter app talks to sensitive
/// backend logic (AI generation, Stripe, social OAuth, scheduling,
/// analytics, AR). No API keys, tokens, or secrets ever live in this file
/// or anywhere else in `frontend/` — they stay server-side in
/// `functions/src/**` per the developer document's security requirement.
class FunctionsService {
  FunctionsService._();
  static final FunctionsService instance = FunctionsService._();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Calls a Cloud Function by name with the given payload and returns its
  /// decoded `data` field. Throws [FirebaseFunctionsException] on failure —
  /// callers should catch this and surface `.message` to the user.
  Future<T> call<T>(String functionName, [Map<String, dynamic>? data]) async {
    // new lines start
    if (kDemoMode) {
      return MockFunctionsService.instance.call<T>(functionName, data!);
    }

    //new lines end
    final callable = _functions.httpsCallable(functionName);
    final result = await callable.call<T>(data ?? <String, dynamic>{});
    return result.data;
  }

  // ---- Convenience typed wrappers for the most-used functions ----

  Future<Map<String, dynamic>> generatePosts(Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('generatePosts', input);

  Future<Map<String, dynamic>> generateContentPlan(
          Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('generateContentPlan', input);

  Future<Map<String, dynamic>> generateCampaign(Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('generateCampaign', input);

  Future<Map<String, dynamic>> generateReviewPost(Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('generateReviewPost', input);

  Future<Map<String, dynamic>> generateContentScore(
          Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('generateContentScore', input);

  Future<Map<String, dynamic>> generateReelScript(Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('generateReelScript', input);

  Future<Map<String, dynamic>> checkPlanAccess([Map<String, dynamic>? input]) =>
      call<Map<String, dynamic>>('checkPlanAccess', input);

  Future<Map<String, dynamic>> createCheckoutSession(
          Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('createCheckoutSession', input);

  Future<Map<String, dynamic>> getBillingPortalUrl() =>
      call<Map<String, dynamic>>('getBillingPortalUrl');

  Future<Map<String, dynamic>> getOAuthUrl(String platform) =>
      call<Map<String, dynamic>>('getOAuthUrl', {'platform': platform});

  Future<Map<String, dynamic>> disconnectSocialAccount(
          String socialAccountId) =>
      call<Map<String, dynamic>>('disconnectSocialAccount', {
        'socialAccountId': socialAccountId,
      });

  Future<Map<String, dynamic>> createScheduledPost(
          Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('createScheduledPost', input);

  Future<Map<String, dynamic>> updateScheduledPost(
          Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('updateScheduledPost', input);

  Future<Map<String, dynamic>> cancelScheduledPost(String scheduledPostId) =>
      call<Map<String, dynamic>>('cancelScheduledPost', {
        'scheduledPostId': scheduledPostId,
      });

  Future<Map<String, dynamic>> generateAnalyticsSummary(
          [Map<String, dynamic>? input]) =>
      call<Map<String, dynamic>>('generateAnalyticsSummary', input);

  Future<Map<String, dynamic>> createArCampaign(Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('createArCampaign', input);

  Future<Map<String, dynamic>> generateArPreview(String arCampaignId) =>
      call<Map<String, dynamic>>(
          'generateArPreview', {'arCampaignId': arCampaignId});

  Future<Map<String, dynamic>> createQrPromo(Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('createQrPromo', input);

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('updateUserProfile', input);

  // ---- Workspace / Team (RBAC) ----

  Future<void> inviteMember(Map<String, dynamic> input) =>
      call<void>('inviteMember', input);

  Future<void> acceptInvite(Map<String, dynamic> input) =>
      call<void>('acceptInvite', input);

  Future<void> updateMemberRole(Map<String, dynamic> input) =>
      call<void>('updateMemberRole', input);

  Future<void> removeMember(Map<String, dynamic> input) =>
      call<void>('removeMember', input);

  Future<void> requestApproval(Map<String, dynamic> input) =>
      call<void>('requestApproval', input);

  Future<void> decideApproval(Map<String, dynamic> input) =>
      call<void>('decideApproval', input);

  // ---- Booking CTA (PDF Section 19) ----

  Future<Map<String, dynamic>> generateBookingCta(Map<String, dynamic> input) =>
      call<Map<String, dynamic>>('generateBookingCta', input);

  // ---- Agency client management (PDF Section 22) ----

  Future<void> createAgencyClient(Map<String, dynamic> input) =>
      call<void>('createAgencyClient', input);

  Future<void> removeAgencyClient(Map<String, dynamic> input) =>
      call<void>('removeAgencyClient', input);
}
