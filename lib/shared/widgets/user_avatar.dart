import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_shadows.dart';
import '../../features/profile/controller/profile_controller.dart';
import 'custom_text.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.size = 44,
    this.onTap,
    this.elevated = false,
  });

  final double size;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      return _circle(size.w, _initials('P', size), elevated);
    }

    final profile = Get.find<ProfileController>();
    return Obx(() {
      final side = size.w;
      final child = profile.hasPhoto
          ? Image.file(
              File(profile.photoPath.value!),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _initials(profile.initials, size),
            )
          : _initials(profile.initials, size);

      return GestureDetector(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: _circle(side, child, elevated),
      );
    });
  }

  static Widget _circle(double side, Widget child, bool elevated) {
    const borderWidth = 1.5;
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: elevated ? AppShadows.soft : AppShadows.none,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.border, width: borderWidth),
        ),
        child: Padding(
          padding: const EdgeInsets.all(borderWidth),
          child: ClipOval(
            child: SizedBox.expand(child: child),
          ),
        ),
      ),
    );
  }

  static Widget _initials(String letters, double designSize) {
    return ColoredBox(
      color: const Color(0xFFE8F0E6),
      child: Center(
        child: CustomText(
          letters,
          fontSize: designSize < 36 ? 13 : 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}
