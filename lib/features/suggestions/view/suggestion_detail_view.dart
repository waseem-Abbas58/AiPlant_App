import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../home/model/suggestion_article.dart';

class SuggestionDetailView extends StatelessWidget {
  const SuggestionDetailView({super.key, required this.article});

  final SuggestionArticle article;

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
                tag: article.imagePath,
                child: Image.asset(
                  article.imagePath,
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
                          AppSpacing.extraLarge.h,
                        ),
                        children: [
                          CustomText(
                            article.category,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen,
                          ),
                          SizedBox(height: AppSpacing.small.h),
                          CustomText(
                            article.title,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                            height: 1.25,
                          ),
                          SizedBox(height: AppSpacing.medium.h),
                          Divider(color: AppColors.divider, height: 1.h),
                          SizedBox(height: AppSpacing.medium.h),
                          for (final section in article.sections) ...[
                            CustomText(
                              section.heading,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                            SizedBox(height: AppSpacing.small.h),
                            for (final paragraph in section.paragraphs) ...[
                              CustomText(
                                paragraph,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.secondaryText,
                                height: 1.5,
                              ),
                              SizedBox(height: AppSpacing.medium.h),
                            ],
                          ],
                        ],
                      ),
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
}
