import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_badge.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class TrendingCard extends StatelessWidget {
  const TrendingCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.badgeText = 'Trending',
    this.width = 148,
    this.height = 210,
    this.onTap,
  });

  final String imagePath;
  final String title;
  final String badgeText;
  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      pressScale: 0.98,
      width: width,
      height: height,
      borderRadius: AppRadius.medium,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Hero(
              tag: imagePath,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.black.withValues(alpha: 0),
                    AppColors.black.withValues(alpha: 0.55),
                  ],
                  stops: const [0.45, 1],
                ),
              ),
            ),
          ),
          if (badgeText.isNotEmpty)
            Positioned(
              top: AppSpacing.small.h,
              left: AppSpacing.small.w,
              child: CustomBadge(
                text: badgeText,
                color: AppColors.black.withValues(alpha: 0.45),
              ),
            ),
          Positioned(
            left: AppSpacing.small.w,
            right: AppSpacing.small.w,
            bottom: AppSpacing.small.h,
            child: CustomText(
              title,
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
