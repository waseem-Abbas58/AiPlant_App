import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../controller/my_garden_controller.dart';
import '../widgets/daily_care_summary.dart';
import '../widgets/garden_subpage_header.dart';
import '../widgets/garden_tasks_tab.dart';

class GardenCareView extends StatelessWidget {
  const GardenCareView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final garden = Get.find<MyGardenController>();
    final body = Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        AppSpacing.small.h,
        AppSpacing.medium.w,
        embedded ? 0 : AppSpacing.medium.h,
      ),
      child: Column(
        children: [
          Obx(() {
            if (garden.plants.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.medium.h),
              child: DailyCareSummary(garden: garden),
            );
          }),
          Expanded(
            child: GardenTasksTab(
              onAddPlant: () => garden.openAddPlantSheet(context),
            ),
          ),
        ],
      ),
    );

    if (embedded) return body;

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
              const GardenSubpageHeader(title: 'Care'),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}
