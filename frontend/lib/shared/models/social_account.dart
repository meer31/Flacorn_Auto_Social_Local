/// Mirrors Firestore path: users/{userId}/socialAccounts/{socialAccountId}
/// (PDF Section 10 & 26).
///
/// NOTE: accessTokenEncrypted / refreshTokenEncrypted are intentionally
/// NOT modeled here — the Flutter app must never read or handle raw or
/// encrypted token values. Firestore security rules also block the client
/// from writing those fields (see firestore.rules).
class SocialAccount {
  final String id;
  final String platform;
  final String accountName;
  final String accountIdFromPlatform;
  final String connectionStatus; // connected | needs_reconnect | disconnected
  final DateTime? lastRefreshedAt;

  const SocialAccount({
    required this.id,
    required this.platform,
    required this.accountName,
    required this.accountIdFromPlatform,
    required this.connectionStatus,
    this.lastRefreshedAt,
  });

  factory SocialAccount.fromMap(String id, Map<String, dynamic> map) {
    return SocialAccount(
      id: id,
      platform: map['platform'] as String? ?? '',
      accountName: map['accountName'] as String? ?? '',
      accountIdFromPlatform: map['accountIdFromPlatform'] as String? ?? '',
      connectionStatus: map['connectionStatus'] as String? ?? 'disconnected',
      lastRefreshedAt: map['lastRefreshedAt'] != null
          ? DateTime.tryParse(map['lastRefreshedAt'].toString())
          : null,
    );
  }

  bool get needsReconnect => connectionStatus == 'needs_reconnect';
}
