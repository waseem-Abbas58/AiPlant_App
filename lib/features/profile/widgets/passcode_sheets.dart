import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_sheet.dart';
import '../controller/profile_controller.dart';
import 'passcode_pad.dart';

Future<void> openPasscodeLock(BuildContext context) async {
  final profile = Get.find<ProfileController>();
  if (profile.passcodeOn.value) {
    await showGardenSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const _ManagePasscodeSheet(),
    );
    return;
  }
  final pin = await showSetPasscodeSheet(context);
  if (pin != null) await profile.enablePasscode(pin);
}

Future<String?> showSetPasscodeSheet(BuildContext context) {
  return showGardenSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const _KeypadSheet(
      title: 'Set Passcode',
      firstHint: 'Enter a 6-digit passcode',
      secondHint: 'Confirm your 6-digit passcode',
    ),
  );
}

Future<bool> showVerifyPasscodeSheet(BuildContext context) async {
  final profile = Get.find<ProfileController>();
  final pin = await showGardenSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _KeypadSheet(
      title: 'Enter Passcode',
      firstHint: 'Enter your 6-digit passcode',
      verify: profile.verifyPasscode,
    ),
  );
  return pin != null;
}

class _ManagePasscodeSheet extends StatelessWidget {
  const _ManagePasscodeSheet();

  @override
  Widget build(BuildContext context) {
    final profile = Get.find<ProfileController>();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        8.h,
        AppSpacing.medium.w,
        20.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          Row(
            children: [
              const Expanded(
                child: CustomText(
                  'Passcode Lock',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
            'Passcode stays on this phone. It does not replace your account sign-in.',
            fontSize: 13,
            color: AppColors.secondaryText,
            height: 1.4,
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomContainer(
            color: AppColors.sageBackground,
            borderRadius: AppRadius.large,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                _ManageRow(
                  title: 'Change passcode',
                  subtitle: 'Verify, then set a new 6-digit code',
                  onTap: () async {
                    final ok = await showVerifyPasscodeSheet(context);
                    if (!ok || !context.mounted) return;
                    final pin = await showSetPasscodeSheet(context);
                    if (pin == null) return;
                    await profile.changePasscode(pin);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
                Divider(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
                _ManageRow(
                  title: 'Disable passcode',
                  subtitle: 'Requires your current passcode',
                  onTap: () async {
                    final ok = await showVerifyPasscodeSheet(context);
                    if (!ok) return;
                    await profile.disablePasscode();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
                Divider(height: 1, color: AppColors.border.withValues(alpha: 0.7)),
                Obx(() {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                'Fingerprint unlock',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                              CustomText(
                                'Use fingerprint after App Lock',
                                fontSize: 13,
                                color: AppColors.secondaryText,
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: profile.biometricOn.value,
                          activeTrackColor: AppColors.primaryGreen,
                          onChanged: (value) {
                            HapticFeedback.selectionClick();
                            profile.setBiometric(value);
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManageRow extends StatelessWidget {
  const _ManageRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  subtitle,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: 20.sp,
            color: AppColors.mutedText,
          ),
        ],
      ),
    );
  }
}

class _KeypadSheet extends StatefulWidget {
  const _KeypadSheet({
    required this.title,
    required this.firstHint,
    this.secondHint,
    this.verify,
  });

  final String title;
  final String firstHint;
  final String? secondHint;
  final bool Function(String pin)? verify;

  @override
  State<_KeypadSheet> createState() => _KeypadSheetState();
}

class _KeypadSheetState extends State<_KeypadSheet> {
  var _pin = '';
  var _first = '';
  var _confirming = false;
  var _error = '';

  bool get _isVerify => widget.verify != null;

  String get _hint {
    if (_error.isNotEmpty) return _error;
    if (_confirming) return widget.secondHint ?? widget.firstHint;
    return widget.firstHint;
  }

  void _digit(String value) {
    if (_pin.length >= 6) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += value;
      _error = '';
    });
    if (_pin.length == 6 && _isVerify) {
      _submitVerify();
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = '';
    });
  }

  void _submitVerify() {
    if (!widget.verify!(_pin)) {
      setState(() {
        _error = 'Wrong passcode. Try again.';
        _pin = '';
      });
      return;
    }
    Navigator.of(context).pop(_pin);
  }

  void _continue() {
    if (_pin.length != 6) return;
    if (_isVerify) {
      _submitVerify();
      return;
    }
    if (!_confirming) {
      setState(() {
        _first = _pin;
        _pin = '';
        _confirming = true;
      });
      return;
    }
    if (_pin != _first) {
      setState(() {
        _error = 'Passcodes do not match.';
        _pin = '';
      });
      return;
    }
    Navigator.of(context).pop(_pin);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _pin.length == 6;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        8.h,
        AppSpacing.medium.w,
        16.h + MediaQuery.paddingOf(context).bottom,
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
              Expanded(
                child: CustomText(
                  widget.title,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const CustomText(
                  'Close',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.large.h),
          CustomText(
            _hint,
            fontSize: 14,
            color: _error.isEmpty ? AppColors.secondaryText : AppColors.error,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.medium.h),
          PasscodeDots(length: _pin.length),
          SizedBox(height: AppSpacing.large.h),
          PasscodePad(
            onDigit: _digit,
            onBackspace: _backspace,
          ),
          if (!_isVerify) ...[
            SizedBox(height: AppSpacing.large.h),
            CustomButton(
              text: _confirming ? 'Confirm passcode' : 'Enable Passcode',
              onPressed: canSubmit ? _continue : null,
              enabled: canSubmit,
              backgroundColor: AppColors.primaryGreen,
              height: 50,
              borderRadius: 14,
            ),
          ],
        ],
      ),
    );
  }
}
