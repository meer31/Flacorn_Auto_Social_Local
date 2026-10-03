/// demo_seed.dart
///
/// Run this ONCE to populate your Firebase project with demo data.
/// After running, the app will look fully alive with real Firestore data.
///
/// HOW TO RUN:
///   1. Make sure you are signed in to Firebase (firebase login)
///   2. Run: flutter run -d chrome --dart-define=DEMO_MODE=true
///   3. Sign in with demo@flacronsocialauto.com / FlacrónDemo2025!
///   4. In the app, call DemoSeeder.seed() once (add a button in settings,
///      or call it from main() the first time)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'demo_config.dart';

class DemoSeeder {
  static final _db = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Creates the demo account and populates Firestore.
  /// Safe to call multiple times — uses set() with merge so it won't
  /// duplicate data.
  static Future<void> seed() async {
    print('[DemoSeeder] Starting...');

    // 1. Create / sign in demo user
    UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: DemoCredentials.email,
        password: DemoCredentials.password,
      );
      print('[DemoSeeder] Created demo user: ${cred.user?.uid}');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        cred = await _auth.signInWithEmailAndPassword(
          email: DemoCredentials.email,
          password: DemoCredentials.password,
        );
        print('[DemoSeeder] Signed in existing demo user: ${cred.user?.uid}');
      } else {
        rethrow;
      }
    }

    final uid = cred.user!.uid;
    final now = FieldValue.serverTimestamp();

    // 2. User profile
    await _db.doc('users/$uid').set({
      'userId': uid,
      'name': 'Sarah Johnson',
      'email': DemoCredentials.email,
      'businessName': DemoBusiness.name,
      'businessCategory': DemoBusiness.category,
      'role': 'owner',
      'timezone': 'America/New_York',
      'mainGoal': DemoBusiness.goal,
      'brandTone': DemoBusiness.tone,
      'bookingLink': DemoBusiness.bookingLink,
      'phoneNumber': DemoBusiness.phone,
      'website': DemoBusiness.website,
      'serviceArea': DemoBusiness.serviceArea,
      'businessHours': DemoBusiness.businessHours,
      'onboardingComplete': true,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    // 3. Pro subscription (active)
    await _db.doc('subscriptions/$uid').set({
      'planName': 'pro',
      'status': 'active',
      'stripeCustomerId': 'cus_demo_001',
      'stripeSubscriptionId': 'sub_demo_001',
      'currentPeriodStart':
          Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 15))),
      'currentPeriodEnd':
          Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
      'aiGenerationLimit': 300,
      'aiGenerationsUsed': 47,
      'scheduledPostLimit': null,
      'scheduledPostsUsed': 23,
      'socialAccountLimit': 10,
      'arAccess': true,
      'agencyAccess': false,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    // 4. Connected social accounts (fake tokens — encrypted string placeholders)
    final accounts = [
      {
        'id': 'instagram_demo_ig001',
        'platform': 'instagram',
        'accountName': DemoBusiness.instagramHandle,
        'accountIdFromPlatform': 'ig_demo_001',
        'accessTokenEncrypted': 'DEMO_ENCRYPTED_TOKEN_INSTAGRAM',
        'refreshTokenEncrypted': null,
        'tokenExpiry':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 55))),
        'connectionStatus': 'connected',
        'metaPageId': 'page_demo_001',
        'metaIgAccountId': 'ig_demo_001',
        'lastRefreshedAt': now,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'facebook_demo_fb001',
        'platform': 'facebook',
        'accountName': DemoBusiness.facebookPage,
        'accountIdFromPlatform': 'fb_demo_001',
        'accessTokenEncrypted': 'DEMO_ENCRYPTED_TOKEN_FACEBOOK',
        'refreshTokenEncrypted': null,
        'tokenExpiry':
            Timestamp.fromDate(DateTime.now().add(const Duration(days: 55))),
        'connectionStatus': 'connected',
        'metaPageId': 'page_demo_001',
        'metaIgAccountId': null,
        'lastRefreshedAt': now,
        'createdAt': now,
        'updatedAt': now,
      },
      {
        'id': 'twitter_demo_tw001',
        'platform': 'twitter',
        'accountName': '@glamourstudionyc',
        'accountIdFromPlatform': 'tw_demo_001',
        'accessTokenEncrypted': 'DEMO_ENCRYPTED_TOKEN_TWITTER',
        'refreshTokenEncrypted': 'DEMO_ENCRYPTED_REFRESH_TWITTER',
        'tokenExpiry':
            Timestamp.fromDate(DateTime.now().add(const Duration(hours: 6))),
        'connectionStatus': 'connected',
        'lastRefreshedAt': now,
        'createdAt': now,
        'updatedAt': now,
      },
    ];

    for (final account in accounts) {
      final id = account['id'] as String;
      await _db.doc('users/$uid/socialAccounts/$id').set(
            {...account}..remove('id'),
            SetOptions(merge: true),
          );
    }

    // 5. Scheduled posts (mix of statuses)
    final posts = [
      _post(
          'Weekend Glow-Up Special ✨ Book your appointment before spots fill!',
          'instagram',
          'instagram_demo_ig001',
          1,
          'pending'),
      _post('Client transformation Tuesday 🔥 Ready for yours?', 'instagram',
          'instagram_demo_ig001', 2, 'pending'),
      _post('3 hair care secrets you NEED to know 💕 Save this!', 'facebook',
          'facebook_demo_fb001', -1, 'sent',
          extId: 'fb_post_001'),
      _post('New service alert 🆕 Brazilian Blowout now available!',
          'instagram', 'instagram_demo_ig001', -3, 'sent',
          extId: 'ig_post_002'),
      _post('Friday vibes — fresh blowout season ✨', 'twitter',
          'twitter_demo_tw001', -5, 'sent',
          extId: 'tw_post_003'),
      _post('Sunday behind the scenes 🎬', 'instagram', 'instagram_demo_ig001',
          -7, 'sent',
          extId: 'ig_post_004'),
      _post('Test post — connection issue', 'instagram', 'instagram_demo_ig001',
          -2, 'failed',
          error: 'Token expired. Please reconnect your Instagram account.'),
      _post('Draft: Monthly promo ideas', 'instagram', 'instagram_demo_ig001',
          10, 'draft'),
    ];

    for (var i = 0; i < posts.length; i++) {
      await _db.doc('users/$uid/scheduledPosts/demo_post_00$i').set(
            posts[i],
            SetOptions(merge: true),
          );
    }

    // 6. Post insights (analytics data)
    final insights = [
      _insight('ig_post_002', 'instagram', 'instagram_demo_ig001', 4200, 3800,
          312, 48, 67, 89, 210),
      _insight('ig_post_004', 'instagram', 'instagram_demo_ig001', 3100, 2800,
          198, 31, 42, 55, 180),
      _insight('fb_post_001', 'facebook', 'facebook_demo_fb001', 2900, 2400,
          143, 27, 89, 0, 320),
      _insight('tw_post_003', 'twitter', 'twitter_demo_tw001', 980, 880, 67, 12,
          34, 0, 45),
    ];

    for (var i = 0; i < insights.length; i++) {
      await _db.doc('users/$uid/postInsights/demo_insight_00$i').set(
            insights[i],
            SetOptions(merge: true),
          );
    }

    // 7. Brand voice
    await _db.doc('users/$uid/brandVoice/profile').set({
      'tone': 'Friendly',
      'audience': 'Women aged 25–45 in NYC looking for premium hair services',
      'style': 'Warm, professional, occasionally playful',
      'preferredCTA': 'Book now at glamourstudio.com/book',
      'wordsToUse': 'glow-up, transformation, luxury, stunning, amazing',
      'wordsToAvoid': 'cheap, discount, basic',
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    // 8. Weekly report
    await _db.doc('users/$uid/weeklyReports/demo_report_001').set({
      'postsPublished': 12,
      'bestPerformingPost': 'Tuesday transformation reel — 4.2K impressions',
      'worstPerformingPost': 'Text-only Monday tip — low visual engagement',
      'mostEffectivePlatform': 'instagram',
      'suggestedImprovements': [
        'Post reels 2× per week',
        'Add booking links to every caption'
      ],
      'recommendedNextWeekContent': [
        'Before/after reel',
        'Team intro post',
        'Weekend promo story'
      ],
      'bestCTA': 'Book now — limited slots this week!',
      'bestContentType': 'reel',
      'suggestedPostingFrequency': '5–6 times per week',
      'weekStart':
          Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))),
      'weekEnd': Timestamp.fromDate(DateTime.now()),
      'createdAt': now,
    }, SetOptions(merge: true));

    // 9. Notifications
    final notifications = [
      {
        'title': 'Post published!',
        'body': 'Your Instagram post went live successfully.',
        'type': 'success'
      },
      {
        'title': 'Reconnect needed',
        'body': 'Your Instagram token expired. Tap to reconnect.',
        'type': 'warning'
      },
      {
        'title': 'Weekly report ready',
        'body': 'Your AI performance report for this week is ready.',
        'type': 'info'
      },
    ];
    for (var i = 0; i < notifications.length; i++) {
      await _db.doc('users/$uid/notifications/demo_notif_00$i').set({
        ...notifications[i],
        'read': false,
        'createdAt':
            Timestamp.fromDate(DateTime.now().subtract(Duration(hours: i * 4))),
      }, SetOptions(merge: true));
    }

    print('[DemoSeeder] ✅ Done! Demo data seeded for uid: $uid');
    print('[DemoSeeder] Email: ${DemoCredentials.email}');
    print('[DemoSeeder] Password: ${DemoCredentials.password}');
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _post(
    String caption,
    String platform,
    String accountId,
    int daysOffset,
    String status, {
    String? extId,
    String? error,
  }) {
    final scheduledAt = DateTime.now().add(Duration(days: daysOffset));
    return {
      'platform': platform,
      'socialAccountRef': 'users/demo/socialAccounts/$accountId',
      'captionText': caption,
      'hashtags': ['#GlamourStudio', '#NYCSalon', '#HairGoals'],
      'mediaUrl': null,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'timezone': 'America/New_York',
      'status': status,
      'externalPostId': extId,
      'errorMessage': error,
      'retryCount': error != null ? 3 : 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _insight(
    String extId,
    String platform,
    String accountId,
    int impressions,
    int reach,
    int likes,
    int comments,
    int shares,
    int saves,
    int clicks,
  ) {
    final interactions = likes + comments + shares + saves + clicks;
    final engRate = impressions > 0
        ? (interactions / impressions * 100).roundToDouble()
        : 0.0;
    return {
      'platform': platform,
      'socialAccountRef': 'users/demo/socialAccounts/$accountId',
      'externalPostId': extId,
      'impressions': impressions,
      'reach': reach,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'saves': saves,
      'clicks': clicks,
      'engagementRate': engRate,
      'fetchedAt': FieldValue.serverTimestamp(),
    };
  }
}
