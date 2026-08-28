import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/profile_locations.dart';

class ProfileLocationField extends StatelessWidget {
  const ProfileLocationField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          'Location',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
        ),
        SizedBox(height: 6.h),
        RawAutocomplete<String>(
          textEditingController: controller,
          focusNode: focusNode,
          optionsBuilder: (value) => ProfileLocations.matching(value.text),
          onSelected: (value) => controller.text = value,
          fieldViewBuilder: (context, fieldController, fieldFocus, onSubmit) {
            return CustomTextField(
              controller: fieldController,
              focusNode: fieldFocus,
              hintText: 'City or country',
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.addressCity],
              isDense: true,
              fillColor: AppColors.sageBackground,
              enabledBorderColor: AppColors.border,
              focusedBorderColor: AppColors.primaryGreen,
              cursorColor: AppColors.primaryGreen,
              borderRadius: 14,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  if (fieldFocus.hasFocus) {
                    fieldFocus.unfocus();
                  } else {
                    fieldFocus.requestFocus();
                  }
                },
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.sp,
                  color: AppColors.mutedText,
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final items = options.toList();
            if (items.isEmpty) {
              return const SizedBox.shrink();
            }
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: AppColors.white,
                elevation: 8,
                clipBehavior: Clip.antiAlias,
                shadowColor: AppColors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.large.r),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 220.h,
                    maxWidth: MediaQuery.sizeOf(context).width -
                        (AppSpacing.medium.w * 2),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.7),
                    ),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        dense: true,
                        title: CustomText(
                          item,
                          fontSize: 14,
                          color: AppColors.primaryText,
                        ),
                        onTap: () => onSelected(item),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
