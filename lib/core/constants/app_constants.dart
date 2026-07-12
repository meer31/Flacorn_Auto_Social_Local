/// Miscellaneous app-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Flacron Auto Social';
  static const String tagline =
      'Your AI Social Media Manager for daily posts, campaigns, AR content, scheduling, analytics, and business growth.';

  /// Supported social platforms in the MVP (PDF Section 10).
  static const List<String> supportedPlatforms = [
    'instagram',
    'facebook',
    'twitter',
    'linkedin',
  ];

  /// Scheduled post status options (PDF Section 14).
  static const List<String> scheduledPostStatuses = [
    'draft',
    'pending',
    'sent',
    'failed',
    'cancelled',
    'needs_reconnect',
  ];

  /// AR campaign types (PDF Section 17).
  static const List<String> arTypes = [
    'promo_preview',
    'product_showcase',
    'qr_promo',
    'before_and_after',
  ];

  /// Scenes available for AR Promo Preview.
  static const List<String> arPreviewScenes = [
    'Storefront',
    'Salon mirror',
    'Office wall',
    'Restaurant table',
    'Real estate yard sign',
    'Phone screen',
    'Poster board',
    'Product display booth',
  ];
}
