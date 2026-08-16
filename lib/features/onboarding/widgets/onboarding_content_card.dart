import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_spacing.dart';
class OnboardingContentCard extends StatelessWidget {
  const OnboardingContentCard({
    super.key,
    required this.heading,
    required this.subtitle,
    required this.footer,
  });
  static const int headingMaxLines = 2;
  static const int subtitleMaxLines = 3;
  static const double subtitleLineHeight = 1.45;

  final Widget heading;
  final Widget subtitle;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final headingStyle = textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final subtitleStyle = textTheme.bodyLarge?.copyWith(
      height: subtitleLineHeight,
    );
    final headingSlotHeight = _reservedTextHeight(
      context: context,
      style: headingStyle,
      maxLines: headingMaxLines,
    );
    final subtitleSlotHeight = _reservedTextHeight(
      context: context,
      style: subtitleStyle,
      maxLines: subtitleMaxLines,
    );
    final footerSlotHeight =
        AppSizes.iconXs.w + AppSpacing.large.h + AppSizes.buttonHeightLg.h;
    final topRadius = Radius.circular(AppRadius.extraLarge.r);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: topRadius,
          topRight: topRadius,
        ),
        boxShadow: AppShadows.soft,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.extraLarge.h,
        AppSpacing.large.w,
        AppSpacing.large.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height:
                headingSlotHeight +
                AppSpacing.extraSmall.h +
                subtitleSlotHeight,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: double.infinity, child: heading),
                SizedBox(height: AppSpacing.extraSmall.h),
                SizedBox(width: double.infinity, child: subtitle),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.large.h),
          SizedBox(
            height: footerSlotHeight,
            width: double.infinity,
            child: Align(
              alignment: Alignment.topCenter,
              child: footer,
            ),
          ),
        ],
      ),
    );
  }

  static double _reservedTextHeight({
    required BuildContext context,
    required TextStyle? style,
    required int maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: 'Hg', style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    return painter.height * maxLines;
  }
}
