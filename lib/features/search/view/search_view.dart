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
import '../../../shared/widgets/custom_search_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/search_controller.dart';

class SearchView extends GetView<SearchViewController> {
  const SearchView({super.key});

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
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.small.w,
                  AppSpacing.small.h,
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                ),
                child: Row(
                  children: [
                    CustomContainer(
                      onTap: NavigationHelper.back,
                      padding: EdgeInsets.all(AppSpacing.small.w),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Expanded(
                      child: CustomSearchField(
                        controller: controller.field,
                        hintText: 'Search plants, tools, tips',
                        fillColor: AppColors.white,
                        borderRadius: AppRadius.large,
                        height: 45,
                        autofocus: true,
                        enableVoice: true,
                        onChanged: controller.onQuery,
                        onSubmitted: controller.onQuery,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  final hits = controller.hits;
                  final emptyQuery = controller.query.value.trim().isEmpty;
                  if (hits.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.large),
                      child: CustomText(
                        'No matches. Try a plant name or a tool.',
                        fontSize: 15,
                        color: AppColors.secondaryText,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.medium.w,
                      AppSpacing.small.h,
                      AppSpacing.medium.w,
                      AppSpacing.large.h,
                    ),
                    itemCount: hits.length + (emptyQuery ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.small.h),
                    itemBuilder: (context, index) {
                      if (emptyQuery && index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: CustomText(
                            'Try a tool or a plant in your garden',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        );
                      }
                      final hit = hits[emptyQuery ? index - 1 : index];
                      return CustomContainer(
                        onTap: () => controller.open(hit),
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        shadow: AppShadows.soft,
                        padding: EdgeInsets.all(AppSpacing.medium.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    hit.title,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  CustomText(
                                    hit.subtitle,
                                    fontSize: 13,
                                    color: AppColors.secondaryText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 20.sp,
                              color: AppColors.mutedText,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
