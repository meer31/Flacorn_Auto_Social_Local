import 'package:flutter/material.dart';

/// Flacron brand color palette.
///
/// Values here match the client-approved Stitch design system exactly
/// (see the Stitch export's `premium_enterprise_ai/DESIGN.md` — the
/// authoritative written spec, not just screenshots). Screens and widgets
/// should always reference [AppColors] rather than hardcoding hex values,
/// so the identity stays consistent and a future rebrand or white-label
/// theme (PDF Section 22: Agency white-label mode) only requires editing
/// this file / [AppTheme].
///
/// STITCH ALIGNMENT NOTE: previous values here were an approximation
/// (#D91E2A / #0E0E10 / #C9A227 / pure-white background) — close in family
/// but not spec-accurate. Updated to exact spec values below. If any
/// screen visually relied on the old, slightly different tones, re-check
/// it after this change — the deltas are small but real (e.g. background
/// is no longer pure white).
class AppColors {
  AppColors._();

  // ---- Brand core (Stitch spec: "Colors") ----
  /// Command Red — primary CTAs, active states, brand signature.
  static const Color flacronRed = Color(0xFFD62828);
  static const Color flacronRedDark = Color(0xFFB20112);
  /// Deep Slate — headers, sidebars, and primary text.
  static const Color flacronBlack = Color(0xFF111827);
  /// AI-insight accent — "smart"/AI-driven features, warnings.
  static const Color flacronGold = Color(0xFFF59E0B);
  static const Color flacronGoldLight = Color(0xFFFBBF6B);

  // ---- Neutrals (light theme) ----
  /// Level 0 — the canvas. NOT pure white (see Level 1 below for that).
  static const Color background = Color(0xFFF8FAFC);
  /// Level 1 — cards/surfaces. Pure white with a 1px #E2E8F0 border.
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF5C5C66);
  static const Color textMuted = Color(0xFF9797A1);

  // ---- Neutrals (dark theme) ----
  static const Color backgroundDark = Color(0xFF0E0E10);
  static const Color surfaceDark = Color(0xFF19191C);
  static const Color surfaceElevatedDark = Color(0xFF222226);
  static const Color borderDark = Color(0xFF303035);
  static const Color textPrimaryDark = Color(0xFFF5F5F7);
  static const Color textSecondaryDark = Color(0xFFB4B4BC);
  static const Color textMutedDark = Color(0xFF7A7A82);

  // ---- Semantic (Stitch spec) ----
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFBA1A1A);
  static const Color info = Color(0xFF2B7DE9);

  // ---- Status colors for scheduled posts (PDF Section 14) ----
  static const Color statusDraft = Color(0xFF9797A1);
  static const Color statusPending = Color(0xFF2B7DE9);
  static const Color statusSent = Color(0xFF22C55E);
  static const Color statusFailed = Color(0xFFBA1A1A);
  static const Color statusCancelled = Color(0xFF5C5C66);
  static const Color statusNeedsReconnect = Color(0xFFF59E0B);

  /// Level 2 (Overlays/Modals) per spec: glassmorphism — 12px blur, 80%
  /// white opacity fill, crisp 1px white border. Use with BackdropFilter;
  /// this is just the fill color, not a full implementation of the blur
  /// (see spec "Elevation & Depth" for the complete recipe).
  static const Color glassOverlayFill = Color(0xCCFFFFFF); // white @ 80%

  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [flacronGold, flacronGoldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redAccentGradient = LinearGradient(
    colors: [flacronRed, flacronRedDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
