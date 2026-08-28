import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class PasscodePad extends StatelessWidget {
  const PasscodePad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Column(
          children: [
            for (final row in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ]) ...[
              Row(
                children: [
                  for (var i = 0; i < row.length; i++) ...[
                    if (i > 0) SizedBox(width: 10.w),
                    Expanded(
                      child: _Key(label: row[i], onTap: () => onDigit(row[i])),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 10.h),
            ],
            Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                SizedBox(width: 10.w),
                Expanded(child: _Key(label: '0', onTap: () => onDigit('0'))),
                SizedBox(width: 10.w),
                Expanded(
                  child: _Key(
                    icon: Icons.backspace_outlined,
                    onTap: onBackspace,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PasscodeDots extends StatelessWidget {
  const PasscodeDots({super.key, required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 6; i++) ...[
          if (i > 0) SizedBox(width: 12.w),
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < length ? AppColors.primaryGreen : Colors.transparent,
              border: Border.all(
                color: i < length ? AppColors.primaryGreen : AppColors.border,
                width: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    this.label,
    this.icon,
    required this.onTap,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(vertical: 14.h),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, size: 22.sp, color: AppColors.primaryText)
          : CustomText(
              label ?? '',
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
    );
  }
}
