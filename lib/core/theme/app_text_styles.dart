import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography scale.
///
/// STITCH ALIGNMENT: the spec (Stitch export's premium_enterprise_ai/
/// DESIGN.md) is explicit — "This design system utilizes Inter
/// exclusively." Headlines previously used Poppins here; switched to
/// Inter throughout to match. Weights/sizes below mirror the spec's
/// typography scale (display-lg 48/700, headline-lg 32/600, title-lg
/// 20/600, body-lg 16/400, body-md 14/400, label-md 12/500 tracked).
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required Color color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static TextStyle headlineLarge(Color color) => _base(
        size: 32,
        weight: FontWeight.w600,
        color: color,
        letterSpacing: -0.32, // spec: -0.01em @ 32px
        height: 1.25,
      );

  static TextStyle headlineMedium(Color color) => _base(
        size: 28,
        weight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle headlineSmall(Color color) => _base(
        size: 20,
        weight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  static TextStyle titleMedium(Color color) =>
      _base(size: 16, weight: FontWeight.w600, color: color);

  static TextStyle bodyLarge(Color color) =>
      _base(size: 16, weight: FontWeight.w400, color: color, height: 1.5);

  static TextStyle bodyMedium(Color color) =>
      _base(size: 14, weight: FontWeight.w400, color: color, height: 1.5);

  static TextStyle bodySmall(Color color) =>
      _base(size: 12, weight: FontWeight.w400, color: color, height: 1.4);

  static TextStyle labelLarge(Color color) => _base(
        size: 14,
        weight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
      );

  static TextStyle caption(Color color) => _base(
        size: 11,
        weight: FontWeight.w500,
        color: color,
        letterSpacing: 0.4,
      );

  /// Convenience getters bound to the light-theme default text color, for
  /// quick usage in widgets that don't need to react to dark mode directly
  /// (prefer Theme.of(context).textTheme for anything dark-mode aware).
  static TextStyle get h1 => headlineLarge(AppColors.textPrimary);
  static TextStyle get h2 => headlineMedium(AppColors.textPrimary);
  static TextStyle get h3 => headlineSmall(AppColors.textPrimary);
  static TextStyle get body => bodyMedium(AppColors.textPrimary);
  static TextStyle get bodyMuted => bodyMedium(AppColors.textSecondary);
}
