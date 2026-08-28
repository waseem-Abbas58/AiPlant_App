import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text.dart';

class QuizWelcomeView extends StatelessWidget {
  const QuizWelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final imagePath = (Get.arguments as String?) ?? AppImages.weeklyQuiz;

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
            alignment: Alignment.bottomCenter,
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
                    'Welcome to the',
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ), 
                  CustomText(
                    'Week 34 Quiz',
                    fontSize: 26,
                    fontWeight: FontWeight.w700, 
                    color: AppColors.primaryText,
                  ),
                  CustomText(
                    'This quiz consists of 3 questions.',
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                  const Spacer(),
                  CustomButton(
                    text: 'Start',
                    onPressed: () {},
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
