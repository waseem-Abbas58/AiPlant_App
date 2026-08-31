import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../model/home_remedy.dart';

class HomeRemedyView extends StatelessWidget {
  const HomeRemedyView({super.key, required this.remedy});

  final HomeRemedy remedy;

  Future<void> _share() async {
    HapticFeedback.selectionClick();
    final steps = [
      for (var i = 0; i < remedy.steps.length; i++)
        '${i + 1}. ${remedy.steps[i]}',
    ].join('\n');
    final body = remedy.hasGuide
        ? '${remedy.title}\n\n'
            'Overview\n${remedy.overview}\n\n'
            'How to use\n$steps\n\n'
            'Why to use\n${remedy.whyToUse}\n\n'
            'When to use\n${remedy.whenToUse}'
        : '${remedy.title}\n\n$steps';
    await SharePlus.instance.share(
      ShareParams(
        text: body,
        subject: remedy.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = 0.42.sh;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: Hero(
                tag: remedy.imagePath,
                child: Image.asset(
                  remedy.imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium.w),
                  child: GestureDetector(
                    onTap: NavigationHelper.back,
                    behavior: HitTestBehavior.opaque,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      child: SizedBox(
                        width: 36.r,
                        height: 36.r,
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.secondaryText,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: imageHeight - 28.h,
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.extraLarge.r),
                  ),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: NavigationHelper.back,
                      onVerticalDragEnd: (details) {
                        final velocity = details.primaryVelocity ?? 0;
                        if (velocity > 280) NavigationHelper.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.small.h,
                        ),
                        child: Center(
                          child: Container(
                            width: 36.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.circular),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.large.w,
                          AppSpacing.small.h,
                          AppSpacing.large.w,
                          AppSpacing.medium.h,
                        ),
                        children: [
                          const CustomText(
                            'Home Remedy',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                          SizedBox(height: AppSpacing.small.h),
                          CustomText(
                            remedy.title,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                            height: 1.25,
                          ),
                          if (remedy.petsNote != null) ...[
                            SizedBox(height: AppSpacing.small.h),
                            CustomContainer(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: AppRadius.medium,
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.small.w,
                                vertical: 10.h,
                              ),
                              child: Row(
                                children: [
                                  CustomContainer(
                                    width: 32,
                                    height: 32,
                                    color: AppColors.white,
                                    borderRadius: AppRadius.medium,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.pets_rounded,
                                      size: 16.sp,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.small.w),
                                  Expanded(
                                    child: CustomText(
                                      remedy.petsNote!,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          SizedBox(height: AppSpacing.medium.h),
                          _GuideSection(
                            title: 'Overview',
                            body: remedy.overview!,
                          ),
                          const _GuideHeading('How to use'),
                          ..._stepRows(remedy.steps),
                          _GuideCallout(
                            title: 'Why to use',
                            body: remedy.whyToUse!,
                            icon: Icons.spa_rounded,
                            filled: true,
                          ),
                          _GuideCallout(
                            title: 'When to use',
                            body: remedy.whenToUse!,
                            icon: Icons.schedule_rounded,
                            filled: false,
                          ),
                          CustomContainer(
                            color: AppColors.white,
                            borderRadius: AppRadius.large,
                            shadow: AppShadows.soft,
                            padding: EdgeInsets.all(AppSpacing.medium.w),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomContainer(
                                  width: 36,
                                  height: 36,
                                  color: AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.medium,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.error,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: AppSpacing.small.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CustomText(
                                        'Caution',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.error,
                                      ),
                                      CustomText(
                                        remedy.caution,
                                        fontSize: 13,
                                        color: AppColors.secondaryText,
                                        height: 1.4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StickyActions(
                      onAsk: () {
                        HapticFeedback.selectionClick();
                        openBotanistChat(
                          plantName: remedy.title,
                          imagePath: remedy.imagePath,
                          isAssetImage: true,
                        );
                      },
                      onShare: remedy.hasGuide ? _share : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Widget> _stepRows(List<String> steps) {
    return [
      for (var i = 0; i < steps.length; i++) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              width: 24,
              height: 24,
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: AppRadius.circular,
              alignment: Alignment.center,
              child: CustomText(
                '${i + 1}',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: CustomText(
                  steps[i], 
                  fontSize: 14, 
                  fontWeight: FontWeight.w400,     
                  color: AppColors.secondaryText,            
                  height: 1.5,        
                ), 
              ),
            ),   
          ],
        ),
        SizedBox(height: AppSpacing.medium.h),
      ],
    ];
  }
}

class _GuideHeading extends StatelessWidget {
  const _GuideHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small.h),
      child: CustomText(
        title,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.medium.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GuideHeading(title),
          CustomText(
            body,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryText,
            height: 1.55,
          ),
        ],
      ),
    );
  }
}

class _StickyActions extends StatelessWidget {
  const _StickyActions({required this.onAsk, this.onShare});

  final VoidCallback onAsk;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.divider),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large.w,
            AppSpacing.small.h,
            AppSpacing.large.w,
            AppSpacing.small.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Ask Botanist',
                  backgroundColor: AppColors.primaryGreen,
                  borderRadius: AppRadius.medium,
                  height: 48,
                  onPressed: onAsk,
                ),
              ),
              if (onShare != null) ...[
                SizedBox(width: AppSpacing.small.w),
                CustomContainer(
                  onTap: onShare,
                  pressScale: 0.98,
                  width: 48,
                  height: 48,
                  color: AppColors.white,
                  borderRadius: AppRadius.medium,
                  border: Border.all(color: AppColors.primaryGreen),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.ios_share_rounded,
                    color: AppColors.primaryGreen,
                    size: 20.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCallout extends StatelessWidget {
  const _GuideCallout({
    required this.title,
    required this.body,
    required this.icon,
    required this.filled,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.medium.h),
      child: CustomContainer(
        color: filled ? AppColors.sageBackground : AppColors.white,
        borderRadius: AppRadius.large,
        border: filled
            ? null
            : Border.all(color: AppColors.border),
        padding: EdgeInsets.all(AppSpacing.medium.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              width: 36,
              height: 36,
              color: filled
                  ? AppColors.white
                  : AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: AppRadius.medium,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 18.sp,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: filled
                        ? AppColors.primaryText
                        : AppColors.primaryGreen,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    body,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
