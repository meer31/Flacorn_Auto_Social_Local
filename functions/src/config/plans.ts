/**
 * Canonical subscription plan definitions.
 *
 * This is the single source of truth for plan limits and feature gates.
 * `checkPlanAccess` (subscriptions/checkPlanAccess.ts) and the Flutter
 * frontend's mirrored constants (frontend/lib/core/constants/plans.dart)
 * must both stay in sync with this file whenever pricing changes.
 */

export type PlanName = "starter" | "pro" | "agency" | "enterprise";

export interface PlanDefinition {
  name: PlanName;
  displayName: string;
  priceMonthlyUsd: number | null; // null = custom/enterprise
  socialAccountLimit: number | null; // null = unlimited
  aiGenerationLimit: number | null;
  scheduledPostLimit: number | null;
  arAccess: boolean;
  arCampaignBuilder: boolean;
  agencyAccess: boolean;
  contentCalendar30Day: boolean;
  campaignGenerator: boolean;
  contentScore: boolean;
  reviewToPostGenerator: boolean;
  bookingCtaGenerator: boolean;
  weeklyAiReport: boolean;
  advancedAnalytics: boolean;
  whiteLabelReports: boolean;
  teamMembers: boolean;
  prioritySupport: boolean;
}

export const PLANS: Record<PlanName, PlanDefinition> = {
  starter: {
    name: "starter",
    displayName: "Starter",
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
  },
  pro: {
    name: "pro",
    displayName: "Pro",
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
  },
  agency: {
    name: "agency",
    displayName: "Agency",
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
  },
  enterprise: {
    name: "enterprise",
    displayName: "Enterprise / White Label",
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
  },
};

/** Add-ons that can be purchased on top of a base plan (Phase 1 groundwork). */
export const ADD_ONS = {
  extraAiGenerations100: { priceUsd: 9, grants: { aiGenerationLimit: 100 } },
  extraSocialAccounts5: { priceUsd: 10, grants: { socialAccountLimit: 5 } },
  arCampaignPackMin: { priceUsd: 19 },
  arCampaignPackMax: { priceUsd: 49 },
  doneForYouSetup: { priceUsd: 99, oneTime: true },
  aiBrandKit: { priceUsd: 29, oneTime: true },
  agencyWhiteLabelMode: { priceUsd: 99 },
  industryTemplatePackMin: { priceUsd: 19 },
  industryTemplatePackMax: { priceUsd: 29 },
};

export function getPlan(name: PlanName): PlanDefinition {
  return PLANS[name];
}
