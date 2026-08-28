import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';

class LegalDocView extends StatelessWidget {
  const LegalDocView.terms({super.key})
      : title = 'Terms of use',
        sections = _terms;

  const LegalDocView.privacy({super.key})
      : title = 'Privacy policy',
        sections = _privacy;

  final String title;
  final List<(String, String)> sections;

  static const _terms = [
    (
      'Using AiPlant',
      'AiPlant helps you identify plants, keep a garden, and ask care questions. You agree to use it for personal, lawful plant care.',
    ),
    (
      'Accounts',
      'Sign-in screens are ready for a live account later. Until then, your profile on this phone is what the app uses.',
    ),
    (
      'Premium',
      'Subscription plans are shown in the app. Nothing is billed until payments go live. Free plan is the default.',
    ),
    (
      'Content',
      'Plant names and care tips in the app are guides, not a substitute for a local botanist or veterinarian for toxicity.',
    ),
    (
      'App Lock',
      'A passcode and fingerprint stay on this device. They do not replace account sign-in.',
    ),
  ];

  static const _privacy = [
    (
      'On this phone',
      'Your photo, name, email, garden, notification choices, ratings, and app lock stay on this device.',
    ),
    (
      'Photos',
      'Identify, disease scan, Ask Botanist, and your profile use photos you take or pick. We do not sell them.',
    ),
    (
      'Permissions',
      'Camera, photos, microphone, and notifications are requested only for those features. You can change them in Privacy → App permissions.',
    ),
    (
      'Delete',
      'Privacy → Delete account removes your profile from this phone. You can create a new one anytime.',
    ),
    (
      'Later services',
      'When cloud accounts and live AI connect, the same Privacy screens will control that data. This policy describes the app as it works today.',
    ),
  ];

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
              GardenSubpageHeader(title: title),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.large.h,
                  ),
                  children: [
                    for (final section in sections) ...[
                      CustomText(
                        section.$1,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      SizedBox(height: 6.h),
                      CustomText(
                        section.$2,
                        fontSize: 14,
                        color: AppColors.secondaryText,
                        height: 1.45,
                      ),
                      SizedBox(height: AppSpacing.large.h),
                    ],
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
