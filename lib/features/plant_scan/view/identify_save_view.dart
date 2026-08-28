import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/controller/my_garden_controller.dart';

class IdentifySaveView extends StatelessWidget {
  const IdentifySaveView({super.key, required this.imagePath});

  final String imagePath;

  Future<void> _save() async {
    if (!Get.isRegistered<MyGardenController>()) return;
    final saved =
        await Get.find<MyGardenController>().saveCapturedPlant(imagePath);
    if (saved) NavigationHelper.back();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.large.w,
              AppSpacing.small.h,
              AppSpacing.large.w,
              AppSpacing.large.h,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomContainer(
                    onTap: NavigationHelper.back,
                    padding: EdgeInsets.all(AppSpacing.small.w),
                    child: Icon(
                      Icons.close_rounded,
                      size: 22.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.extraLarge.r),
                  child: Image.file(
                    File(imagePath),
                    width: 240.w,
                    height: 240.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: AppColors.nearBlack,
                      child: SizedBox(width: 240.w, height: 240.w),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.extraLarge.h),
                const CustomText(
                  'Save this plant?',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.small.h),
                const CustomText(
                  'Add it to your garden, or keep the snap in history.',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFD0D0D0),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                CustomButton(
                  text: 'Save to garden',
                  backgroundColor: AppColors.primaryGreen,
                  textColor: AppColors.white,
                  onPressed: _save,
                ),
                SizedBox(height: AppSpacing.small.h),
                CustomContainer(
                  onTap: NavigationHelper.back,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
                  child: const CustomText(
                    'Not now',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
