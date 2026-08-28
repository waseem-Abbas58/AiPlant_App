import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/validators/validators.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_password_field.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    NavigationHelper.back();
    CustomSnackbar.success(message: 'Password updated.');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          child: Column(
            children: [
              const GardenSubpageHeader(title: 'Change password'),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.medium.w,
                      AppSpacing.small.h,
                      AppSpacing.medium.w,
                      AppSpacing.large.h,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      const GardenPopIn(
                        child: CustomText(
                          'Password is never shown. It stays hidden as dots on Personal data.',
                          fontSize: 13,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      GardenPopIn(
                        delay: const Duration(milliseconds: 40),
                        child: _PasswordBlock(
                          label: 'Current password',
                          controller: _current,
                          textInputAction: TextInputAction.next,
                          validator: (value) => Validators.required(
                            value,
                            fieldName: 'Current password',
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium.h),
                      GardenPopIn(
                        delay: const Duration(milliseconds: 80),
                        child: _PasswordBlock(
                          label: 'New password',
                          controller: _next,
                          textInputAction: TextInputAction.next,
                          validator: Validators.password,
                        ),
                      ),
                      SizedBox(height: AppSpacing.medium.h),
                      GardenPopIn(
                        delay: const Duration(milliseconds: 120),
                        child: _PasswordBlock(
                          label: 'Confirm new password',
                          controller: _confirm,
                          textInputAction: TextInputAction.done,
                          validator: (value) => Validators.confirmPassword(
                            value,
                            _next.text,
                          ),
                          onSubmitted: (_) => _save(),
                        ),
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      GardenPopIn(
                        delay: const Duration(milliseconds: 160),
                        child: CustomButton(
                          text: 'Update password',
                          onPressed: _save,
                          backgroundColor: AppColors.primaryGreen,
                          height: 50,
                          borderRadius: 14,
                        ),
                      ),
                    ],
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

class _PasswordBlock extends StatelessWidget {
  const _PasswordBlock({
    required this.label,
    required this.controller,
    required this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
        ),
        SizedBox(height: 6.h),
        CustomPasswordField(
          controller: controller,
          hintText: '••••••••',
          textInputAction: textInputAction ?? TextInputAction.next,
          validator: validator,
          onSubmitted: onSubmitted,
          isDense: true,
          fillColor: AppColors.white,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryGreen,
          cursorColor: AppColors.primaryGreen,
          borderRadius: 14,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
        ),
      ],
    );
  }
}
