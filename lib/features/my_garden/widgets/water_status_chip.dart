import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../data/plant_care_engine.dart';

class WaterStatusChip extends StatelessWidget {
  const WaterStatusChip({super.key, required this.status});

  final PlantWaterStatus status;

  String get _label => switch (status) {
        PlantWaterStatus.fresh => 'Just watered',
        PlantWaterStatus.due => 'Due now',
        PlantWaterStatus.dry => 'Getting dry',
        PlantWaterStatus.ok => 'Looking good',
      };

  Color get _color => switch (status) {
        PlantWaterStatus.fresh => AppColors.blue,
        PlantWaterStatus.due => AppColors.warning,
        PlantWaterStatus.dry => AppColors.warning,
        PlantWaterStatus.ok => AppColors.primaryGreen,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return CustomContainer(
      color: color.withValues(alpha: 0.12),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: AppSpacing.extraSmall.h + 2.h,
      ),
      child: CustomText(
        _label,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
