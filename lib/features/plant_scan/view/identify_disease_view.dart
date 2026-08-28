import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../data/plant_identify_repository.dart';
import '../model/plant_identify_result.dart';
import '../../chatbot/data/botanist_navigator.dart';

class IdentifyDiseaseView extends StatefulWidget {
  const IdentifyDiseaseView({
    super.key,
    required this.imagePath,
    this.plantName = '',
  });

  final String imagePath;
  final String plantName;

  @override
  State<IdentifyDiseaseView> createState() => _IdentifyDiseaseViewState();
}

class _IdentifyDiseaseViewState extends State<IdentifyDiseaseView> {
  PlantDiseaseHint? _hint;
  var _loading = true;

  PlantIdentifyRepository get _repository {
    if (Get.isRegistered<PlantIdentifyRepository>()) {
      return Get.find<PlantIdentifyRepository>();
    }
    return LocalPlantIdentifyRepository();
  }

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final hint = await _repository.diagnoseFromImage(widget.imagePath);
    if (!mounted) return;
    setState(() {
      _hint = hint;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hint = _hint;
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: Column(
          children: [
            SizedBox(
              height: 240.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.imagePath.startsWith('assets/')
                      ? Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: AppColors.nearBlack,
                          ),
                        ),
                  Positioned(
                    top: top + 8.h,
                    left: AppSpacing.medium.w,
                    child: CustomContainer(
                      onTap: NavigationHelper.back,
                      width: 36,
                      height: 36,
                      color: AppColors.white.withValues(alpha: 0.94),
                      borderRadius: AppRadius.circular,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading || hint == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.medium.w,
                        AppSpacing.large.h,
                        AppSpacing.medium.w,
                        AppSpacing.extraLarge.h,
                      ),
                      children: [
                        if (hint.isLocalPreview) ...[
                          CustomContainer(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: AppRadius.circular,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            child: const CustomText(
                              'Preview — live diagnosis when AI is connected',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          SizedBox(height: AppSpacing.medium.h),
                        ],
                        CustomContainer(
                          color: hint.healthy
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: AppRadius.circular,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          child: CustomText(
                            hint.healthy ? 'Looks healthy' : 'Possible issue',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: hint.healthy
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        SizedBox(height: AppSpacing.small.h),
                        CustomText(
                          hint.title,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          letterSpacing: -0.4,
                        ),
                        SizedBox(height: AppSpacing.small.h),
                        CustomText(
                          hint.summary,
                          fontSize: 15,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                        if (hint.steps.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.large.h),
                          const CustomText(
                            'What to do',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                          SizedBox(height: AppSpacing.small.h),
                          for (var i = 0; i < hint.steps.length; i++) ...[
                            if (i > 0) SizedBox(height: AppSpacing.small.h),
                            CustomContainer(
                              color: AppColors.white,
                              borderRadius: AppRadius.large,
                              shadow: AppShadows.soft,
                              padding: EdgeInsets.all(AppSpacing.medium.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomContainer(
                                    width: 28,
                                    height: 28,
                                    color: AppColors.sageBackground,
                                    borderRadius: AppRadius.circular,
                                    alignment: Alignment.center,
                                    child: CustomText(
                                      '${i + 1}',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.small.w),
                                  Expanded(
                                    child: CustomText(
                                      hint.steps[i],
                                      fontSize: 14,
                                      color: AppColors.primaryText,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                        SizedBox(height: AppSpacing.large.h),
                        CustomContainer(
                          onTap: () => openBotanistChat(
                            plantName: widget.plantName,
                            imagePath: widget.imagePath,
                          ),
                          color: AppColors.white,
                          borderRadius: AppRadius.large,
                          shadow: AppShadows.soft,
                          padding: EdgeInsets.all(AppSpacing.medium.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: AppColors.primaryGreen,
                                size: 22.sp,
                              ),
                              SizedBox(width: AppSpacing.small.w),
                              const Expanded(
                                child: CustomText(
                                  'Ask Botanist',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.mutedText,
                                size: 22.sp,
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
    );
  }
}
