import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'garden_sheet.dart';

Future<String?> showDiaryNoteSheet(BuildContext context) {
  return showGardenSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _DiaryNoteSheet(),
  );
}

class _DiaryNoteSheet extends StatefulWidget {
  const _DiaryNoteSheet();

  @override
  State<_DiaryNoteSheet> createState() => _DiaryNoteSheetState();
}

class _DiaryNoteSheetState extends State<_DiaryNoteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.small.h,
        AppSpacing.large.w,
        AppSpacing.large.h +
            MediaQuery.paddingOf(context).bottom +
            bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CustomContainer(
              width: 36,
              height: 4,
              color: AppColors.divider,
              borderRadius: AppRadius.circular,
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          const CustomText(
            'Growth note',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            letterSpacing: -0.28,
          ),
          SizedBox(height: AppSpacing.small.h),
          const CustomText(
            'Optional caption for this photo.',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomTextField(
            controller: _controller,
            hintText: 'New leaf, first bloom…',
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            fillColor: AppColors.sageBackground,
            focusedBorderColor: AppColors.primaryGreen,
            cursorColor: AppColors.primaryGreen,
            onSubmitted: (_) => _save(),
          ),
          SizedBox(height: AppSpacing.large.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  backgroundColor: AppColors.sageBackground,
                  textColor: AppColors.primaryText,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(width: AppSpacing.small.w),
              Expanded(
                child: CustomButton(
                  text: 'Save photo',
                  backgroundColor: AppColors.primaryGreen,
                  textColor: AppColors.white,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
