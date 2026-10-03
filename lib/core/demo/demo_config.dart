/// demo_config.dart
///
/// Set [kDemoMode] to true before showing to the client.
/// Set it back to false when you have all real credentials.
///
/// Usage:
///   flutter run -d chrome --dart-define=DEMO_MODE=true
///
/// Or hardcode during demo period:
///   const kDemoMode = true;

const bool kDemoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: false);

/// Demo user credentials — pre-created in Firebase Auth.
/// Run the seed script once to create this account.
class DemoCredentials {
  static const email = '';
  static const password = '';
  static const uid = 'demo_user_001'; // set after seeding
}

/// Realistic business info shown throughout the demo.
class DemoBusiness {
  static const name = 'Glamour Studio NYC';
  static const category = 'Hair / Beauty';
  static const goal = 'Get more bookings';
  static const tone = 'Friendly';
  static const bookingLink = 'https://glamourstudio.com/book';
  static const phone = '+1 (212) 555-0182';
  static const website = 'https://glamourstudio.com';
  static const serviceArea = 'New York City, NY';
  static const businessHours = 'Tue–Sat 9am–7pm';
  static const instagramHandle = '@glamourstudionyc';
  static const facebookPage = 'Glamour Studio NYC';
}
