import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/repository_providers.dart';

/// Local, in-memory draft of onboarding answers as the user progresses
/// through the multi-step flow (PDF Section 8). Persisted to Firestore via
/// `updateUserProfile` at each step (and again as a final confirmation),
/// so partially-completed onboarding is never silently lost even if the
/// underlying Cloud Function calls happen incrementally.
class OnboardingDraft {
  final String businessName;
  final String website;
  final String phoneNumber;
  final String city;
  final String timezone;
  final String businessCategory;
  final String mainGoal;
  final String brandTone;
  final String selectedPlan; // starter | pro | agency

  const OnboardingDraft({
    this.businessName = '',
    this.website = '',
    this.phoneNumber = '',
    this.city = '',
    this.timezone = 'UTC',
    this.businessCategory = '',
    this.mainGoal = '',
    this.brandTone = '',
    this.selectedPlan = 'pro',
  });

  OnboardingDraft copyWith({
    String? businessName,
    String? website,
    String? phoneNumber,
    String? city,
    String? timezone,
    String? businessCategory,
    String? mainGoal,
    String? brandTone,
    String? selectedPlan,
  }) {
    return OnboardingDraft(
      businessName: businessName ?? this.businessName,
      website: website ?? this.website,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      city: city ?? this.city,
      timezone: timezone ?? this.timezone,
      businessCategory: businessCategory ?? this.businessCategory,
      mainGoal: mainGoal ?? this.mainGoal,
      brandTone: brandTone ?? this.brandTone,
      selectedPlan: selectedPlan ?? this.selectedPlan,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingDraft> {
  OnboardingController(this._ref) : super(const OnboardingDraft());

  final Ref _ref;

  void updateBusinessProfile({
    required String businessName,
    required String website,
    required String phoneNumber,
    required String city,
    required String timezone,
  }) {
    state = state.copyWith(
      businessName: businessName,
      website: website,
      phoneNumber: phoneNumber,
      city: city,
      timezone: timezone,
    );
  }

  void selectCategory(String category) => state = state.copyWith(businessCategory: category);
  void selectGoal(String goal) => state = state.copyWith(mainGoal: goal);
  void selectTone(String tone) => state = state.copyWith(brandTone: tone);
  void selectPlan(String plan) => state = state.copyWith(selectedPlan: plan);

  /// Persists the current draft to Firestore via `updateUserProfile`.
  /// Called at the end of each relevant step so progress survives an app
  /// restart mid-onboarding.
  Future<void> persist() async {
    final repo = _ref.read(userRepositoryProvider);
    await repo.updateProfile({
      'businessName': state.businessName,
      'website': state.website,
      'phoneNumber': state.phoneNumber,
      'city': state.city,
      'timezone': state.timezone,
      'businessCategory': state.businessCategory,
      'mainGoal': state.mainGoal,
      'brandTone': state.brandTone,
    });
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingDraft>(
  (ref) => OnboardingController(ref),
);
