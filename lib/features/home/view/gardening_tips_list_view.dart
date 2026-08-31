import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';
import '../model/gardening_tip.dart';
import '../widgets/horizontal_content_card.dart';
import 'gardening_tip_view.dart';

class GardeningTipsListView extends StatelessWidget {
  const GardeningTipsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = GardeningTip.catalog;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              const GardenSubpageHeader(title: 'Gardening Tips'),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.extraLarge.h,
                  ),
                  itemCount: tips.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: AppSpacing.small.h),
                  itemBuilder: (_, index) {
                    final tip = tips[index];
                    return HorizontalContentCard(
                      expand: true,
                      imagePath: tip.imagePath,
                      title: tip.listTitle,
                      subtitle: tip.cardLine,
                      color: AppColors.white,
                      titleMaxLines: 1,
                      subtitleMaxLines: 3,
                      heroTag: 'list-${tip.imagePath}',
                      onTap: () => GardeningTipView.open(
                        tip,
                        heroTag: 'list-${tip.imagePath}',
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
