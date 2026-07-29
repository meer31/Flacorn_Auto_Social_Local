/// Mirrors functions/src/config/plans.ts — keep both files in sync whenever
/// pricing or feature gates change. This copy is used purely for frontend
/// display/UX (showing limits, upgrade prompts, locked-feature badges);
/// the backend is always the source of truth and re-validates every
/// plan-gated action server-side.
library plans;

enum PlanName { starter, pro, agency, enterprise }

class PlanDefinition {
  final PlanName name;
  final String displayName;
  final double? priceMonthlyUsd;
  final int? socialAccountLimit;
  final int? aiGenerationLimit;
  final int? scheduledPostLimit;
  final bool arAccess;
  final bool arCampaignBuilder;
  final bool agencyAccess;
  final bool contentCalendar30Day;
  final bool campaignGenerator;
  final bool contentScore;
  final bool reviewToPostGenerator;
  final bool bookingCtaGenerator;
  final bool weeklyAiReport;
  final bool advancedAnalytics;
  final bool whiteLabelReports;
  final bool teamMembers;
  final bool prioritySupport;

  const PlanDefinition({
    required this.name,
    required this.displayName,
    required this.priceMonthlyUsd,
    required this.socialAccountLimit,
    required this.aiGenerationLimit,
    required this.scheduledPostLimit,
    required this.arAccess,
    required this.arCampaignBuilder,
    required this.agencyAccess,
    required this.contentCalendar30Day,
    required this.campaignGenerator,
    required this.contentScore,
    required this.reviewToPostGenerator,
    required this.bookingCtaGenerator,
    required this.weeklyAiReport,
    required this.advancedAnalytics,
    required this.whiteLabelReports,
    required this.teamMembers,
    required this.prioritySupport,
  });
}

const Map<PlanName, PlanDefinition> kPlans = {
  PlanName.starter: PlanDefinition(
    name: PlanName.starter,
    displayName: 'Starter',
    priceMonthlyUsd: 29,
    socialAccountLimit: 3,
    aiGenerationLimit: 10,
    scheduledPostLimit: 10,
    arAccess: false,
    arCampaignBuilder: false,
    agencyAccess: false,
    contentCalendar30Day: false,
    campaignGenerator: false,
    contentScore: false,
    reviewToPostGenerator: false,
    bookingCtaGenerator: false,
    weeklyAiReport: false,
    advancedAnalytics: false,
    whiteLabelReports: false,
    teamMembers: false,
    prioritySupport: false,
  ),
  PlanName.pro: PlanDefinition(
    name: PlanName.pro,
    displayName: 'Pro',
    priceMonthlyUsd: 79,
    socialAccountLimit: 10,
    aiGenerationLimit: 300,
    scheduledPostLimit: null,
    arAccess: true,
    arCampaignBuilder: false,
    agencyAccess: false,
    contentCalendar30Day: true,
    campaignGenerator: true,
    contentScore: true,
    reviewToPostGenerator: true,
    bookingCtaGenerator: true,
    weeklyAiReport: true,
    advancedAnalytics: true,
    whiteLabelReports: false,
    teamMembers: false,
    prioritySupport: false,
  ),
  PlanName.agency: PlanDefinition(
    name: PlanName.agency,
    displayName: 'Agency',
    priceMonthlyUsd: 199,
    socialAccountLimit: 30,
    aiGenerationLimit: null,
    scheduledPostLimit: null,
    arAccess: true,
    arCampaignBuilder: true,
    agencyAccess: true,
    contentCalendar30Day: true,
    campaignGenerator: true,
    contentScore: true,
    reviewToPostGenerator: true,
    bookingCtaGenerator: true,
    weeklyAiReport: true,
    advancedAnalytics: true,
    whiteLabelReports: true,
    teamMembers: true,
    prioritySupport: true,
  ),
  PlanName.enterprise: PlanDefinition(
    name: PlanName.enterprise,
    displayName: 'Enterprise / White Label',
    priceMonthlyUsd: null,
    socialAccountLimit: null,
    aiGenerationLimit: null,
    scheduledPostLimit: null,
    arAccess: true,
    arCampaignBuilder: true,
    agencyAccess: true,
    contentCalendar30Day: true,
    campaignGenerator: true,
    contentScore: true,
    reviewToPostGenerator: true,
    bookingCtaGenerator: true,
    weeklyAiReport: true,
    advancedAnalytics: true,
    whiteLabelReports: true,
    teamMembers: true,
    prioritySupport: true,
  ),
};
