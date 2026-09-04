import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class IdentifyResultTabs {
  static const care = 0;
  static const health = 1;
  static const more = 2;
  static const labels = ['Care', 'Health', 'More'];
}

class IdentifyResultTabBar extends StatelessWidget {
  const IdentifyResultTabBar({
    super.key,
    required this.selected,
    required this.onSelect,
    this.elevated = false,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.sageBackground,
        boxShadow: elevated ? AppShadows.soft : AppShadows.none,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.medium.w,
          6.h,
          AppSpacing.medium.w,
          8.h,
        ),
        child: CustomContainer(
          color: AppColors.white,
          borderRadius: AppRadius.circular,
          shadow: AppShadows.soft,
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              for (var i = 0; i < IdentifyResultTabs.labels.length; i++)
                Expanded(
                  child: CustomContainer(
                    onTap: () => onSelect(i),
                    color: selected == i
                        ? AppColors.primaryGreen
                        : Colors.transparent,
                    borderRadius: AppRadius.circular,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    child: CustomText(
                      IdentifyResultTabs.labels[i],
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected == i
                          ? AppColors.white
                          : AppColors.secondaryText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class IdentifyResultPinHeader extends SliverPersistentHeaderDelegate {
  IdentifyResultPinHeader({
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  double get minExtent => 56.h;

  @override
  double get maxExtent => 56.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return IdentifyResultTabBar(
      selected: selected,
      onSelect: onSelect,
      elevated: overlapsContent || shrinkOffset > 0,
    );
  }

  @override
  bool shouldRebuild(IdentifyResultPinHeader oldDelegate) {
    return oldDelegate.selected != selected;
  }
}
