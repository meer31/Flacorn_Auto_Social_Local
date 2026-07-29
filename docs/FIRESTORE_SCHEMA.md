# Firestore Schema

Mirrors developer document Section 26 exactly. All timestamps are Firestore
server timestamps unless noted. All paths starting with `users/{userId}/`
are owned exclusively by that user (see `firestore.rules`).

## `users/{userId}`
```
{
  name, email, businessName, businessCategory, role, timezone,
  mainGoal, brandTone, createdAt, updatedAt
}
```

## `subscriptions/{userId}`
```
{
  planName, stripeCustomerId, stripeSubscriptionId, status,
  currentPeriodStart, currentPeriodEnd,
  aiGenerationLimit, aiGenerationsUsed,
  scheduledPostLimit, scheduledPostsUsed,
  socialAccountLimit, socialAccountsUsed,
  arAccess, agencyAccess, createdAt, updatedAt
}
```
Client: read-only. Written exclusively by Cloud Functions (Stripe webhook,
admin override, onboarding provisioning).

## `users/{userId}/socialAccounts/{socialAccountId}`
```
{
  platform, accountName, accountIdFromPlatform,
  accessTokenEncrypted, refreshTokenEncrypted, tokenExpiry,
  connectionStatus, lastRefreshedAt, createdAt, updatedAt
}
```
Client: may read; may NOT write `accessTokenEncrypted` /
`refreshTokenEncrypted` / `tokenExpiry` (enforced by Firestore rules).

## `users/{userId}/postTemplates/{templateId}`
```
{
  platform, title, postIdea, captionText, hashtags, cta, mediaUrl,
  contentScore, suggestedDateTime, createdBy, createdAt, updatedAt
}
```

## `users/{userId}/scheduledPosts/{postId}`
```
{
  platform, socialAccountRef, captionText, hashtags, mediaUrl,
  scheduledAt, timezone, status, externalPostId, errorMessage,
  retryCount, createdAt, updatedAt
}
```
`status`: `draft | pending | sent | failed | cancelled | needs_reconnect`

## `users/{userId}/postInsights/{insightId}`
```
{
  platform, socialAccountRef, scheduledPostRef, externalPostId,
  impressions, reach, likes, comments, shares, saves, clicks,
  engagementRate, fetchedAt
}
```
Client: read-only. Written by `collectInsights` only.

## `users/{userId}/contentPlans/{planId}`
```
{ planName, businessCategory, goal, startDate, endDate, posts, status, createdAt, updatedAt }
```

## `users/{userId}/campaigns/{campaignId}`
```
{ campaignName, campaignType, goal, startDate, endDate, posts, arEnabled, status, createdAt, updatedAt }
```

## `users/{userId}/arCampaigns/{arCampaignId}`
```
{ campaignName, arType, sourceMediaUrl, previewScene, generatedPreviewUrl, qrCodeUrl, linkedPostRef, status, createdAt, updatedAt }
```

## `users/{userId}/businessSettings/{settingsId}`
```
{ bookingLink, phoneNumber, website, promoCode, serviceArea, businessHours, defaultCTA, createdAt, updatedAt }
```

## `users/{userId}/brandVoice/{brandVoiceId}`
```
{ tone, audience, style, preferredCTA, wordsToUse, wordsToAvoid, createdAt, updatedAt }
```

## `users/{userId}/media/{mediaId}`
```
{ url, fileName, createdAt }
```

## `users/{userId}/notifications/{notificationId}`
```
{ type, title, message, actionRoute, read, readAt, createdAt }
```
Client: may only update `read` / `readAt`.

## `users/{userId}/weeklyReports/{reportId}`
```
{
  weekOf, postsPublished, bestPerformingPost, worstPerformingPost,
  mostEffectivePlatform, suggestedImprovements, recommendedNextWeekContent,
  bestCta, bestContentType, suggestedPostingFrequency, createdAt, updatedAt
}
```
Client: read-only. Written by `generateWeeklyReport` only.

## `agencies/{agencyId}/clients/{clientId}`
Phase 2 full build-out; MVP-ready structure per PDF Section 22.

## `auditLogs/{logId}`
```
{ userId, action, resourceType, resourceId, ipAddress, userAgent, createdAt }
```
Client: no access except admins (read-only).

## `_rateLimits/{userId}_{bucket}` (internal)
Used by `middleware/rateLimiter.ts`. Not part of the public schema; no
client access.
