import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_borders.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/otp_verification_controller.dart';
import 'auth_shared_widgets.dart';

class AuthOtpInput extends StatelessWidget {
  const AuthOtpInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasError,
    this.length = OtpVerificationController.otpLength,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final RxBool hasError;
  final int length;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verification code, 6 digits',
      textField: true,
      child: SizedBox(
      height: AppSizes.buttonHeightMd.h,
      child: Stack(
        children: [
          Obx(() {
            final error = hasError.value;
            return AnimatedBuilder(
              animation: Listenable.merge([controller, focusNode]),
              builder: (context, _) {
                final code = controller.text;
                final focused = focusNode.hasFocus;
                final activeIndex =
                    code.length >= length ? length - 1 : code.length;

                return Row(
                  children: [
                    for (var i = 0; i < length; i++) ...[
                      if (i > 0) SizedBox(width: AppSpacing.small.w),
                      Expanded(
                        child: _OtpCell(
                          digit: i < code.length ? code[i] : '',
                          focused: focused && !error && i == activeIndex,
                          hasError: error,
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          }),
          Positioned.fill(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              enableSuggestions: false,
              showCursor: false,
              enableInteractiveSelection: true,
              style: const TextStyle(
                color: Colors.transparent,
                fontSize: 1,
                height: 0.01,
              ),
              cursorColor: Colors.transparent,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(length),
              ],
              autofillHints: const [AutofillHints.oneTimeCode],
              onSubmitted: (_) => onSubmitted?.call(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                filled: true,
                fillColor: Colors.transparent,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  const _OtpCell({
    required this.digit,
    required this.focused,
    required this.hasError,
  });

  final String digit;
  final bool focused;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Color borderColor;
    final double borderWidth;

    if (hasError) {
      borderColor = AppColors.error;
      borderWidth = AppBorders.widthRegular;
    } else if (focused) {
      borderColor = AuthFormStyle.focus;
      borderWidth = AppBorders.widthThick;
    } else {
      borderColor = AppColors.border;
      borderWidth = AppBorders.widthRegular;
    }

    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeOutCubic,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AuthFormStyle.fill,
        borderRadius: BorderRadius.circular(AuthFormStyle.fieldRadius.r),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: CustomText(
        digit,
        style: textTheme.titleMedium?.copyWith(
          height: 1.2,
          letterSpacing: 0,
        ),
        color: AppColors.primaryText,
        fontWeight: FontWeight.w700,
        textAlign: TextAlign.center,
      ),
    );
  }
}
