/// Mirrors Firestore path: users/{userId} (PDF Section 26).
///
/// This is identity/profile data only. Content and team membership now
/// live under workspaces/{workspaceId}/** — see shared/models/workspace.dart.
class UserProfile {
  final String userId;
  final String name;
  final String email;
  final String businessName;
  final String businessCategory;
  @Deprecated(
    'Always "owner" from the old single-tenant model. Role is now per-'
    'workspace — see WorkspaceMember.role via WorkspaceRepository.getMyMembership().',
  )
  final String role;
  final String timezone;
  final String mainGoal;
  final String brandTone;

  /// The workspace this user lands in by default. A user may belong to
  /// more than one workspace (e.g. invited as a teammate elsewhere) —
  /// this is just which one opens on sign-in, not the only one they can
  /// access. See WorkspaceRepository.watchMembers for the full list.
  final String? defaultWorkspaceId;

  // ---- Business / Booking CTA settings (PDF Section 19) ----
  final String? bookingLink;
  final String? phoneNumber;
  final String? website;
  final String? promoCode;
  final String? serviceArea;
  final String? businessHours;
  final String? defaultCTA;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.businessName,
    required this.businessCategory,
    required this.role,
    required this.timezone,
    required this.mainGoal,
    required this.brandTone,
    this.defaultWorkspaceId,
    this.bookingLink,
    this.phoneNumber,
    this.website,
    this.promoCode,
    this.serviceArea,
    this.businessHours,
    this.defaultCTA,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      userId: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      businessName: map['businessName'] as String? ?? '',
      businessCategory: map['businessCategory'] as String? ?? '',
      role: map['role'] as String? ?? 'owner',
      timezone: map['timezone'] as String? ?? 'UTC',
      mainGoal: map['mainGoal'] as String? ?? '',
      brandTone: map['brandTone'] as String? ?? '',
      defaultWorkspaceId: map['defaultWorkspaceId'] as String?,
      bookingLink: map['bookingLink'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      website: map['website'] as String?,
      promoCode: map['promoCode'] as String?,
      serviceArea: map['serviceArea'] as String?,
      businessHours: map['businessHours'] as String?,
      defaultCTA: map['defaultCTA'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'businessName': businessName,
      'businessCategory': businessCategory,
      'role': role,
      'timezone': timezone,
      'mainGoal': mainGoal,
      'brandTone': brandTone,
      'defaultWorkspaceId': defaultWorkspaceId,
      if (bookingLink != null) 'bookingLink': bookingLink,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (website != null) 'website': website,
      if (promoCode != null) 'promoCode': promoCode,
      if (serviceArea != null) 'serviceArea': serviceArea,
      if (businessHours != null) 'businessHours': businessHours,
      if (defaultCTA != null) 'defaultCTA': defaultCTA,
    };
  }
}
