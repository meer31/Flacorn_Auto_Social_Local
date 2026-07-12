import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

/// Skeleton loading placeholder (UI/UX requirement: "Skeleton loading
/// screens"). Wrap any not-yet-loaded card/list-tile shape in this.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    required this.width,
    required this.height,
    this.borderRadius = 8,
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for a full-width card, used while dashboard/analytics/list data
/// is loading from Firestore or a Cloud Function call.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({this.height = 96, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(width: double.infinity, height: height, borderRadius: 16);
  }
}
