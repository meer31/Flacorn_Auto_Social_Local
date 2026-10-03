/// mock_functions_service.dart
///
/// Drop-in replacement for FunctionsService during demo mode.
/// Every method returns realistic, pre-crafted data instantly —
/// no Firebase Functions, no API keys, no external services needed.
///
/// HOW IT WORKS:
///   FunctionsService checks kDemoMode and delegates to this class.
///   The Flutter app never knows the difference.

import 'package:flutter/material.dart';

class MockFunctionsService {
  MockFunctionsService._();
  static final instance = MockFunctionsService._();

  // ── Artificial delay to make it feel like a real network call ──────────────
  Future<void> _delay([int ms = 900]) =>
      Future.delayed(Duration(milliseconds: ms));

  // ══════════════════════════════════════════════════════════════════════════
  // AI GENERATION
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> generatePosts(Map<String, dynamic> data) async {
    await _delay(1200);
    return {
      'posts': [
        {
          'title': 'Weekend Glow-Up Special',
          'postIdea': 'Promote weekend availability with a limited offer',
          'captionText':
              '✨ Your hair deserves the best this weekend! Book your glow-up '
                  'appointment and walk out feeling like a million dollars. '
                  'Limited slots available — don\'t wait! 💇‍♀️',
          'hashtags': [
            '#HairGoals',
            '#GlamourStudio',
            '#NYCSalon',
            '#HairCare',
            '#BookNow'
          ],
          'cta': 'Book now at glamourstudio.com/book',
          'platform': data['platform'] ?? 'instagram',
          'suggestedDateTime': _dateFromNow(1),
          'mediaType': 'image',
          'contentScore': 91,
          'reelIdea':
              'Before/after transformation in 15 seconds with trending audio',
          'storyVersion':
              '✨ Weekend slots just dropped! Swipe up to book yours.',
        },
        {
          'title': 'Client Transformation Tuesday',
          'postIdea': 'Show a real client result with permission',
          'captionText':
              'Meet our client Sarah — she came in wanting a change and left '
                  'absolutely STUNNING! 🔥 Ready for your transformation? '
                  'DM us or tap the link in bio to book.',
          'hashtags': [
            '#TransformationTuesday',
            '#HairTransformation',
            '#SalonLife',
            '#GlamourNYC'
          ],
          'cta': 'DM us to book your transformation',
          'platform': data['platform'] ?? 'instagram',
          'suggestedDateTime': _dateFromNow(2),
          'mediaType': 'carousel',
          'contentScore': 88,
          'reelIdea': 'Side-by-side before/after reel with dramatic reveal',
          'storyVersion':
              'Transformation unlocked 🔓 — link in bio to book yours!',
        },
        {
          'title': 'Hair Care Tips Wednesday',
          'postIdea': 'Educational content builds trust and saves time',
          'captionText':
              '3 things your hair is BEGGING you to stop doing 🚫\n\n'
                  '1️⃣ Skipping heat protectant\n'
                  '2️⃣ Washing with hot water\n'
                  '3️⃣ Brushing wet hair aggressively\n\n'
                  'Save this post and share with a friend who needs it! 💕',
          'hashtags': [
            '#HairTips',
            '#HairCareRoutine',
            '#HealthyHair',
            '#SalonAdvice'
          ],
          'cta': 'Follow for weekly hair tips',
          'platform': data['platform'] ?? 'instagram',
          'suggestedDateTime': _dateFromNow(3),
          'mediaType': 'carousel',
          'contentScore': 85,
          'reelIdea': 'Quick tips reel — 3 cuts in 30 seconds',
          'storyVersion': '3 habits killing your hair 😬 (save this!)',
        },
        {
          'title': 'New Arrival: Brazilian Treatment',
          'postIdea': 'Announce a new service to drive curiosity',
          'captionText': '🆕 Now offering Brazilian Blowout treatments! '
              'Say goodbye to frizz for up to 12 WEEKS. ✨ '
              'Our clients are OBSESSED and we know you will be too. '
              'Book your consultation today — spots fill fast!',
          'hashtags': [
            '#BrazilianBlowout',
            '#FrizzFree',
            '#NewService',
            '#GlamourStudio'
          ],
          'cta': 'Book your consultation: glamourstudio.com/book',
          'platform': data['platform'] ?? 'instagram',
          'suggestedDateTime': _dateFromNow(4),
          'mediaType': 'image',
          'contentScore': 87,
        },
        {
          'title': 'Friday Feel-Good',
          'postIdea': 'Light, relatable Friday content drives engagement',
          'captionText':
              'Friday mood: fresh blowout, good vibes, zero bad hair days 💁‍♀️✨ '
                  'Tag a friend who needs a salon date this weekend! '
                  'Walk-ins welcome Saturday 10am–3pm 🎉',
          'hashtags': [
            '#FridayVibes',
            '#FreshBlowout',
            '#SalonDay',
            '#GlamourNYC',
            '#WalkInsWelcome'
          ],
          'cta': 'Walk-ins welcome this Saturday!',
          'platform': data['platform'] ?? 'instagram',
          'suggestedDateTime': _dateFromNow(5),
          'mediaType': 'reel',
          'contentScore': 83,
        },
        {
          'title': 'Google Review Spotlight',
          'postIdea': 'Social proof — repost a 5-star review',
          'captionText':
              '⭐⭐⭐⭐⭐ "Best salon in NYC — I\'ve been coming here for 2 years '
                  'and every single time I leave feeling amazing. The team is '
                  'so talented and professional!" — Maria G.\n\n'
                  'Thank you, Maria! 🙏 This is why we love what we do. '
                  'Ready to experience Glamour Studio? Book below 👇',
          'hashtags': [
            '#ClientLove',
            '#5StarSalon',
            '#NYCSalon',
            '#HappyClients'
          ],
          'cta': 'Book at glamourstudio.com/book',
          'platform': data['platform'] ?? 'instagram',
          'suggestedDateTime': _dateFromNow(6),
          'mediaType': 'image',
          'contentScore': 89,
        },
        {
          'title': 'Behind the Scenes Sunday',
          'postIdea': 'BTS content humanises the brand',
          'captionText':
              'A Sunday at Glamour Studio 🎬 From our morning setup to '
                  'the last client of the day — this is what love for our '
                  'craft looks like. Every client deserves to feel beautiful. '
                  'See you this week! 💕',
          'hashtags': [
            '#BehindTheScenes',
            '#SalonLife',
            '#HairstylistLife',
            '#GlamourStudio'
          ],
          'cta': 'Book your next appointment with us',
          'platform': data['platform'] ?? 'instagram',
          'suggestedDateTime': _dateFromNow(7),
          'mediaType': 'video',
          'contentScore': 82,
        },
      ],
    };
  }

  Future<Map<String, dynamic>> generateContentPlan(
      Map<String, dynamic> data) async {
    await _delay(2000);
    final posts = List.generate(
        30,
        (i) => {
              'day': i + 1,
              'title': _planTitles[i % _planTitles.length],
              'postIdea': 'Strategic content for day ${i + 1}',
              'captionText': _planCaptions[i % _planCaptions.length],
              'hashtags': ['#GlamourStudio', '#NYCSalon', '#HairGoals'],
              'cta': 'Book at glamourstudio.com/book',
              'platform': [
                'instagram',
                'facebook',
                'instagram',
                'twitter'
              ][i % 4],
              'suggestedDate': _dateOnly(i + 1),
              'mediaType': [
                'image',
                'reel',
                'carousel',
                'story',
                'image'
              ][i % 5],
              'contentScore': 75 + (i % 20),
              'arRecommended': i % 7 == 0,
            });

    return {'planName': '30-Day Beauty Business Growth Plan', 'posts': posts};
  }

  Future<Map<String, dynamic>> generateCampaign(
      Map<String, dynamic> data) async {
    await _delay(1500);
    return {
      'campaignName': '${data['campaignType'] ?? 'Promotion'} Campaign',
      'posts': List.generate(
          8,
          (i) => {
                'title': 'Campaign Post ${i + 1}',
                'captionText': _campaignCaptions[i % _campaignCaptions.length],
                'hashtags': ['#GlamourStudio', '#SalonPromo', '#BookNow'],
                'cta': 'Book now — limited slots!',
                'platform': ['instagram', 'facebook'][i % 2],
                'suggestedDate': _dateOnly(i + 1),
                'mediaType': ['image', 'reel', 'story'][i % 3],
                'storyIdea': 'Countdown story with swipe-up booking link',
                'reelIdea':
                    'Fast montage of transformations with promo overlay',
              }),
    };
  }

  Future<Map<String, dynamic>> generateReviewPost(
      Map<String, dynamic> data) async {
    await _delay(1000);
    final review = data['review'] ?? 'Amazing experience!';
    return {
      'caption': '⭐⭐⭐⭐⭐ We are blown away by this review! ✨\n\n'
          '"$review"\n\n'
          'This is exactly why we pour our hearts into every appointment. '
          'Ready to experience it yourself? Book below 👇',
      'testimonialPost': '"$review" — A happy Glamour Studio client 💕\n\n'
          'We\'re grateful for every client who trusts us with their hair. '
          'Book your experience at glamourstudio.com/book',
      'storyCaption':
          '❤️ This review made our day!\n\nSwipe up to book your appointment.',
      'hashtags': [
        '#ClientLove',
        '#HappyClients',
        '#NYCSalon',
        '#GlamourStudio',
        '#5Stars'
      ],
      'bookingCta':
          'Book your appointment now: glamourstudio.com/book — Limited slots this week!',
    };
  }

  Future<Map<String, dynamic>> generateContentScore(
      Map<String, dynamic> data) async {
    await _delay(800);
    return {
      'contentScore': 87,
      'recommendation':
          'Strong caption with good emotional appeal. Add a clearer booking '
              'CTA with a direct link to improve conversion potential.',
      'breakdown': {
        'hookStrength': 90,
        'clarity': 88,
        'ctaQuality': 78,
        'hashtagQuality': 85,
        'platformFit': 92,
        'conversionPotential': 80,
        'emotionalAppeal': 91,
      },
    };
  }

  Future<Map<String, dynamic>> generateWeeklyReport(
      Map<String, dynamic> _) async {
    await _delay(1500);
    return {
      'postsPublished': 12,
      'bestPerformingPost':
          'Client transformation Tuesday reel — 4.2K impressions',
      'worstPerformingPost':
          'Text-only tip post on Monday — low visual engagement',
      'mostEffectivePlatform': 'instagram',
      'suggestedImprovements': [
        'Post reels 2× per week — they outperform static images by 3×',
        'Add booking links to every caption, not just bio',
        'Respond to comments within 2 hours to boost algorithm reach',
      ],
      'recommendedNextWeekContent': [
        'Before/after transformation reel',
        'Team introduction post — builds personal connection',
        'Limited-time weekend promo story',
        'Educational hair tip carousel',
      ],
      'bestCTA': 'Book now — limited slots this week!',
      'bestContentType': 'reel',
      'suggestedPostingFrequency': '5–6 times per week',
    };
  }

  Future<Map<String, dynamic>> generateBookingCta(
      Map<String, dynamic> _) async {
    await _delay(900);
    return {
      'ctas': [
        'Book your transformation today → glamourstudio.com/book',
        'Limited slots this week — reserve yours now!',
        'DM us "BOOK" to schedule your appointment 📲',
        'Call us at (212) 555-0182 — walk-ins welcome Sat!',
        'Your glow-up is one click away → link in bio 💇‍♀️',
        'Only 3 spots left this Saturday — book now!',
        'Treat yourself — you deserve it. Book today ✨',
        'New clients save 15% — use code GLAMOUR15 at checkout',
        'Schedule your free consultation → glamourstudio.com/book',
        'Don\'t wait — our calendar fills up fast! Book now 📅',
      ],
    };
  }

  Future<Map<String, dynamic>> generateReelScript(
      Map<String, dynamic> data) async {
    await _delay(1000);
    return {
      'hook': 'POV: You finally found your forever salon 😍',
      'scenes': [
        {
          'timeCode': '0:00–0:03',
          'action': 'Walk-in shot of salon entrance',
          'voiceover': 'Welcome to Glamour Studio NYC',
          'onScreenText': 'NYC\'s #1 hair salon'
        },
        {
          'timeCode': '0:03–0:10',
          'action': 'Quick cuts of services',
          'voiceover': 'Where every client leaves feeling amazing',
          'onScreenText': 'Cuts • Color • Blowouts • Treatments'
        },
        {
          'timeCode': '0:10–0:20',
          'action': 'Before/after transformation',
          'voiceover': 'Real results, every time',
          'onScreenText': 'Swipe to see more transformations'
        },
        {
          'timeCode': '0:20–0:30',
          'action': 'Booking CTA screen',
          'voiceover': 'Book your appointment today',
          'onScreenText': 'glamourstudio.com/book 📲'
        },
      ],
      'cta': 'Book your appointment — link in bio!',
      'caption':
          'Your new salon era starts here ✨ Book your appointment at glamourstudio.com/book',
      'hashtags': ['#NYCSalon', '#HairGoals', '#GlamourStudio', '#SalonReel'],
      'musicMood': 'upbeat',
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ANALYTICS
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> generateAnalyticsSummary(
      Map<String, dynamic> data) async {
    await _delay(800);
    final is7Day = (data['rangeDays'] ?? 30) == 7;
    return {
      'rangeDays': data['rangeDays'] ?? 30,
      'totalPosts': is7Day ? 18 : 67,
      'totalReach': is7Day ? 12480 : 48920,
      'totalEngagementActions': is7Day ? 843 : 3240,
      'overallEngagementRate': is7Day ? 6.8 : 6.6,
      'bestTimeToPostUtcHour': 19,
      'reachByPlatform': {
        'instagram': is7Day ? 8200 : 32400,
        'facebook': is7Day ? 2800 : 10800,
        'twitter': is7Day ? 980 : 3620,
        'linkedin': is7Day ? 500 : 2100,
      },
      'topPosts': [
        {
          'platform': 'instagram',
          'captionText': 'Client transformation Tuesday reel 🔥',
          'engagementRate': 12.4,
          'impressions': 4200
        },
        {
          'platform': 'instagram',
          'captionText': 'Weekend glow-up special ✨',
          'engagementRate': 9.1,
          'impressions': 3800
        },
        {
          'platform': 'facebook',
          'captionText': 'New Brazilian Blowout service! 🆕',
          'engagementRate': 7.3,
          'impressions': 2900
        },
      ],
      'worstPosts': [
        {
          'platform': 'twitter',
          'captionText': 'Quick hair tip for the day',
          'engagementRate': 1.2,
          'impressions': 340
        },
      ],
      'byPlatform': {
        'instagram': {
          'posts': is7Day ? 10 : 38,
          'impressions': is7Day ? 9800 : 38400
        },
        'facebook': {
          'posts': is7Day ? 5 : 18,
          'impressions': is7Day ? 3200 : 12600
        },
        'twitter': {
          'posts': is7Day ? 2 : 8,
          'impressions': is7Day ? 1100 : 4200
        },
        'linkedin': {
          'posts': is7Day ? 1 : 3,
          'impressions': is7Day ? 580 : 2200
        },
      },
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SUBSCRIPTION / PLAN ACCESS
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> checkPlanAccess(Map<String, dynamic> _) async {
    await _delay(200);
    return {
      'hasAccess': true,
      'planName': 'Pro',
      'aiGenerationsUsed': 47,
      'aiGenerationLimit': 300,
      'scheduledPostsUsed': 23,
      'scheduledPostLimit': null,
      'socialAccountLimit': 10,
      'arAccess': true,
      'agencyAccess': false,
    };
  }

  Future<Map<String, dynamic>> incrementUsage(Map<String, dynamic> _) async {
    await _delay(100);
    return {'success': true};
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STRIPE — Mock checkout (shows demo banner, no real payment)
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> createCheckoutSession(
      Map<String, dynamic> data) async {
    await _delay(500);
    // Return a special demo URL — handled by DemoBillingBypass widget
    return {'url': 'demo://activate-plan/${data['plan'] ?? 'pro'}'};
  }

  Future<Map<String, dynamic>> getBillingPortalUrl(
      Map<String, dynamic> _) async {
    await _delay(300);
    return {'url': 'demo://billing-portal'};
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SOCIAL OAUTH — Fake connect flow (no real OAuth)
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getOAuthUrl(Map<String, dynamic> data) async {
    await _delay(300);
    final platform = data['platform'] ?? 'instagram';
    // Return a demo:// URL — handled by DemoOAuthBypass widget
    return {'url': 'demo://connect-account/$platform'};
  }

  Future<Map<String, dynamic>> disconnectSocialAccount(
      Map<String, dynamic> _) async {
    await _delay(400);
    return {'success': true};
  }

  Future<Map<String, dynamic>> refreshTokenIfNeeded(
      Map<String, dynamic> _) async {
    await _delay(200);
    return {'refreshed': false};
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SCHEDULING
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> createScheduledPost(
      Map<String, dynamic> _) async {
    await _delay(600);
    return {'postId': 'demo_post_${DateTime.now().millisecondsSinceEpoch}'};
  }

  Future<Map<String, dynamic>> updateScheduledPost(
      Map<String, dynamic> _) async {
    await _delay(400);
    return {'success': true};
  }

  Future<Map<String, dynamic>> cancelScheduledPost(
      Map<String, dynamic> _) async {
    await _delay(400);
    return {'success': true};
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AR
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> createArCampaign(
      Map<String, dynamic> data) async {
    await _delay(700);
    return {'campaignId': 'demo_ar_${DateTime.now().millisecondsSinceEpoch}'};
  }

  Future<Map<String, dynamic>> generateArPreview(
      Map<String, dynamic> data) async {
    await _delay(1200);
    return {
      'previewUrl':
          'https://via.placeholder.com/800x600/FF4444/FFFFFF?text=AR+Preview',
      'scene': data['scene'] ?? 'storefront',
      'status': 'ready',
    };
  }

  Future<Map<String, dynamic>> createQrPromo(Map<String, dynamic> data) async {
    await _delay(1000);
    return {
      'qrCodeUrl':
          'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${Uri.encodeComponent(data['promoUrl'] ?? 'https://glamourstudio.com/book')}',
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AGENCY / TEAM
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> createAgencyClient(
      Map<String, dynamic> data) async {
    await _delay(600);
    return {'clientId': 'demo_client_${DateTime.now().millisecondsSinceEpoch}'};
  }

  Future<Map<String, dynamic>> removeAgencyClient(
      Map<String, dynamic> _) async {
    await _delay(400);
    return {'success': true};
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMIN
  // ══════════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> listUsers(Map<String, dynamic> _) async {
    await _delay(800);
    return {
      'users': [
        {
          'uid': 'u1',
          'email': 'sarah@salon.com',
          'businessName': 'Glamour Studio',
          'planName': 'pro',
          'subStatus': 'active',
          'aiUsed': 47,
          'postsUsed': 23,
          'disabled': false
        },
        {
          'uid': 'u2',
          'email': 'mike@realty.com',
          'businessName': 'Mike\'s Real Estate',
          'planName': 'starter',
          'subStatus': 'active',
          'aiUsed': 8,
          'postsUsed': 6,
          'disabled': false
        },
        {
          'uid': 'u3',
          'email': 'agency@market.com',
          'businessName': 'Marketing Plus',
          'planName': 'agency',
          'subStatus': 'active',
          'aiUsed': 180,
          'postsUsed': 94,
          'disabled': false
        },
        {
          'uid': 'u4',
          'email': 'coach@fitlife.com',
          'businessName': 'FitLife Coaching',
          'planName': 'starter',
          'subStatus': 'inactive',
          'aiUsed': 2,
          'postsUsed': 1,
          'disabled': false
        },
      ],
      'nextPageToken': null,
      'totalCount': 4,
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Generic call dispatcher — routes by function name
  // ══════════════════════════════════════════════════════════════════════════

  Future<T> call<T>(String functionName, Map<String, dynamic> data) async {
    final result = await _dispatch(functionName, data);
    return result as T;
  }

  Future<Map<String, dynamic>> _dispatch(
      String name, Map<String, dynamic> data) {
    switch (name) {
      case 'generatePosts':
        return generatePosts(data);
      case 'generateContentPlan':
        return generateContentPlan(data);
      case 'generateCampaign':
        return generateCampaign(data);
      case 'generateReviewPost':
        return generateReviewPost(data);
      case 'generateContentScore':
        return generateContentScore(data);
      case 'generateWeeklyReport':
        return generateWeeklyReport(data);
      case 'generateReelScript':
        return generateReelScript(data);
      case 'generateBookingCta':
        return generateBookingCta(data);
      case 'generateAnalyticsSummary':
        return generateAnalyticsSummary(data);
      case 'checkPlanAccess':
        return checkPlanAccess(data);
      case 'incrementUsage':
        return incrementUsage(data);
      case 'createCheckoutSession':
        return createCheckoutSession(data);
      case 'getBillingPortalUrl':
        return getBillingPortalUrl(data);
      case 'getOAuthUrl':
        return getOAuthUrl(data);
      case 'disconnectSocialAccount':
        return disconnectSocialAccount(data);
      case 'refreshTokenIfNeeded':
        return refreshTokenIfNeeded(data);
      case 'createScheduledPost':
        return createScheduledPost(data);
      case 'updateScheduledPost':
        return updateScheduledPost(data);
      case 'cancelScheduledPost':
        return cancelScheduledPost(data);
      case 'createArCampaign':
        return createArCampaign(data);
      case 'generateArPreview':
        return generateArPreview(data);
      case 'createQrPromo':
        return createQrPromo(data);
      case 'createAgencyClient':
        return createAgencyClient(data);
      case 'removeAgencyClient':
        return removeAgencyClient(data);
      case 'listUsers':
        return listUsers(data);
      default:
        return Future.value({'success': true, 'demo': true});
    }
  }

  // ── Sample data helpers ───────────────────────────────────────────────────

  String _dateFromNow(int daysAhead) {
    final d = DateTime.now().add(Duration(days: daysAhead));
    return d.toIso8601String();
  }

  String _dateOnly(int daysAhead) {
    final d = DateTime.now().add(Duration(days: daysAhead));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static const _planTitles = [
    'Weekend Special Promo',
    'Client Transformation',
    'Hair Care Tips',
    'New Service Announcement',
    'Friday Feel-Good',
    'Review Spotlight',
    'Behind the Scenes',
    'Team Introduction',
    'Before & After',
    'Limited Time Offer',
  ];

  static const _planCaptions = [
    '✨ Your transformation is just one appointment away! Book today → glamourstudio.com/book',
    '💇‍♀️ Fresh hair, fresh start. Limited slots available this week — book now!',
    '3 hair care secrets your stylist wants you to know 👇 Save this post!',
    '🆕 Exciting news! We just added a new service you\'re going to LOVE.',
    'Friday feeling = fresh blowout + good vibes ✨ Tag someone who needs a salon day!',
  ];

  static const _campaignCaptions = [
    '🎉 Our biggest promotion of the year is HERE! Don\'t miss out — book today!',
    '✨ Limited time offer — treat yourself this weekend. You deserve it!',
    '⏰ Only 48 hours left! Book your appointment before spots fill up.',
    '💕 Share this with a friend and BOTH get 10% off your next visit!',
    '🔥 Last chance — promotion ends Sunday at midnight!',
  ];
}
