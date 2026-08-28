import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_sheet.dart';

Future<void> showRateAppSheet(BuildContext context) {
  return showGardenSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _RateAppSheet(),
  );
}

class _RateAppSheet extends StatefulWidget {
  const _RateAppSheet();

  @override
  State<_RateAppSheet> createState() => _RateAppSheetState();
}

class _RateAppSheetState extends State<_RateAppSheet> {
  static const _key = 'profile_app_rating';
  var _stars = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _stars = prefs.getInt(_key) ?? 0);
  }

  Future<void> _submit() async {
    if (_stars < 1) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _stars);
    if (!mounted) return;
    NavigationHelper.back();
    CustomSnackbar.success(message: 'Thanks for the rating.');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        8.h,
        AppSpacing.medium.w,
        20.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          Row(
            children: [
              const Expanded(
                child: CustomText(
                  'Rate AiPlant',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              GestureDetector(
                onTap: NavigationHelper.back,
                child: const CustomText(
                  'Close',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const CustomText(
            'How does the app feel so far?',
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: AppSpacing.large.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++) ...[
                if (i > 1) SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _stars = i);
                  },
                  child: Icon(
                    i <= _stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36.sp,
                    color: i <= _stars
                        ? AppColors.primaryGreen
                        : AppColors.mutedText,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: AppSpacing.large.h),
          CustomButton(
            text: 'Submit',
            onPressed: _stars > 0 ? _submit : null,
            enabled: _stars > 0,
            backgroundColor: AppColors.primaryGreen,
            height: 50,
            borderRadius: 14,
          ),
        ],
      ),
    );
  }
}
