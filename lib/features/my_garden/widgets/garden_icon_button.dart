import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../shared/widgets/custom_container.dart';

class GardenIconButton extends StatelessWidget {
  const GardenIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final iconColor = emphasized ? AppColors.white : AppColors.primaryText;
    final fill = emphasized ? AppColors.primaryGreen : AppColors.white;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: CustomContainer(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        color: fill,
        borderRadius: AppRadius.circular,
        shadow: AppShadows.soft,
        alignment: Alignment.center,
        padding: EdgeInsets.all(9.r),
        child: Icon(icon, size: 20.sp, color: iconColor),
      ),
    );
  }
}
