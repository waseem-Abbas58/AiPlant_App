import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_image.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';
import '../widgets/profile_setting_row.dart';
import 'faq_view.dart';
import 'legal_doc_view.dart';
import 'rate_app_sheet.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          child: Column(
            children: [
              const GardenSubpageHeader(title: 'About'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.large.h,
                  ),
                  children: [
                    GardenPopIn(
                      child: CustomContainer(
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        shadow: AppShadows.soft,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.large.h,
                          horizontal: AppSpacing.medium.w,
                        ),
                        child: Column(
                          children: [
                            CustomImage(
                              assetPath: AppImages.authLogo,
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: AppSpacing.small.h),
                            CustomText(
                              AppConfig.appName,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              'Version ${AppConfig.appVersion}',
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.large.h),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 40),
                      child: ProfileSettingRow(
                        icon: Icons.help_outline_rounded,
                        title: 'FAQ',
                        subtitle: 'Identify, garden, botanist, lock',
                        onTap: () => NavigationHelper.to(() => const FaqView()),
                      ),
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 80),
                      child: ProfileSettingRow(
                        icon: Icons.star_outline_rounded,
                        title: 'Rate us',
                        subtitle: 'Tell us how AiPlant feels',
                        onTap: () => showRateAppSheet(context),
                      ),
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 120),
                      child: ProfileSettingRow(
                        icon: Icons.description_outlined,
                        title: 'Terms of use',
                        subtitle: 'How you can use the app',
                        onTap: () => NavigationHelper.to(
                          () => const LegalDocView.terms(),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.small.h),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 160),
                      child: ProfileSettingRow(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy policy',
                        subtitle: 'What we keep on this phone',
                        onTap: () => NavigationHelper.to(
                          () => const LegalDocView.privacy(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
