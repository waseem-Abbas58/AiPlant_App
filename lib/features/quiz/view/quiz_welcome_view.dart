import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/weekly_quiz.dart';
import 'quiz_play_view.dart';

class QuizWelcomeView extends StatelessWidget {
  const QuizWelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final imagePath = (Get.arguments as String?) ?? AppImages.weeklyQuiz;
    final count = WeeklyQuiz.questions.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.sageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: NavigationHelper.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            alignment: const Alignment(-0.12, 0.42),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            width: 96.w,
            height: 220.h,
            child: const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0x00F4F6F3),
                      AppColors.sageBackground,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 160.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.sageBackground.withValues(alpha: 0),
                      AppColors.sageBackground,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                0,
                AppSpacing.medium.w,
                AppSpacing.medium.h,
              ),
              child: Column(
                children: [
                  CustomText(
                    '${WeeklyQuiz.weekLabel} Quiz',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                  SizedBox(height: AppSpacing.small.h),
                  CustomText(
                    WeeklyQuiz.prompt,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.medium.h),
                  CustomContainer(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: AppRadius.circular,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.medium.w,
                      vertical: AppSpacing.extraSmall.h + 2,
                    ),
                    child: CustomText(
                      '$count questions',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const Spacer(),
                  CustomButton(
                    text: 'Start',
                    onPressed: () => NavigationHelper.to(
                      () => const QuizPlayView(),
                    ),
                    backgroundColor: AppColors.primaryGreen,
                    textColor: AppColors.white,
                    borderRadius: AppRadius.medium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
