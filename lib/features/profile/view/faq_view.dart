import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  static const _items = [
    (
      'How do I identify a plant?',
      'Open Scan or Garden +, take a photo, then use the result. You can save it to My Garden.',
    ),
    (
      'How do watering reminders work?',
      'Each plant has a care schedule (water, mist, fertilizer, rotate, cut). Turn those alerts on in Profile → Notifications, and set a reminder time.',
    ),
    (
      'What is Ask Botanist?',
      'Chat for plant-care questions. Attach a leaf photo or pick a plant from your garden.',
    ),
    (
      'Where is my data stored?',
      'Profile, garden, notifications, and app lock stay on this phone. Delete account in Privacy if you want them removed here.',
    ),
    (
      'How does App Lock work?',
      'Set a 6-digit passcode in Privacy. Optional fingerprint unlocks after that. Four wrong codes pause for 1 hour; two more pause for 48 hours.',
    ),
    (
      'What is Premium?',
      'The Subscription screen shows plans. Nothing is billed yet. Free plan is the current default.',
    ),
    (
      'How do I delete my account?',
      'Profile → Privacy → Delete account. This removes your profile from this phone.',
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
              const GardenSubpageHeader(title: 'FAQ'),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.large.h,
                  ),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.small.h),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return GardenPopIn(
                      delay: Duration(milliseconds: 30 * index),
                      child: CustomContainer(
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        border: Border.all(color: AppColors.border),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            splashColor: AppColors.primaryGreen
                                .withValues(alpha: 0.08),
                          ),
                          child: ExpansionTile(
                            tilePadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.medium.w,
                            ),
                            childrenPadding: EdgeInsets.fromLTRB(
                              AppSpacing.medium.w,
                              0,
                              AppSpacing.medium.w,
                              AppSpacing.medium.h,
                            ),
                            iconColor: AppColors.primaryGreen,
                            collapsedIconColor: AppColors.mutedText,
                            title: CustomText(
                              item.$1,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                            children: [
                              CustomText(
                                item.$2,
                                fontSize: 13,
                                color: AppColors.secondaryText,
                                height: 1.45,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
