import 'dart:async';

import 'package:ai_plant_app/features/profile/widgets/passcode_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/profile_controller.dart';

class AppLockView extends StatefulWidget {
  const AppLockView({super.key});

  @override
  State<AppLockView> createState() => _AppLockViewState();
}

class _AppLockViewState extends State<AppLockView> {
  final _auth = LocalAuthentication();
  var _pin = '';
  var _error = '';
  var _bioTried = false;
  Timer? _ticker;

  ProfileController get _profile => Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _profile.refreshLockout();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeBiometric());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _maybeBiometric() async {
    if (_bioTried) return;
    _bioTried = true;
    if (!_profile.biometricOn.value || _profile.isLockedOut) return;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    await _biometric();
  }

  Future<void> _biometric() async {
    if (_profile.isLockedOut || !_profile.biometricOn.value) return;
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock AiPlant',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (ok) _profile.unlockWithBiometric();
    } catch (_) {}
  }

  Future<void> _digit(String value) async {
    if (_profile.isLockedOut || _pin.length >= 6) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += value;
      _error = '';
    });
    if (_pin.length < 6) return;
    final ok = await _profile.tryUnlock(_pin);
    if (!mounted) return;
    if (ok) return;
    setState(() {
      _pin = '';
      _error = _profile.isLockedOut
          ? _profile.lockoutLabel
          : 'Wrong passcode. Try again.';
    });
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: AppColors.sageBackground,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.large.w,
              AppSpacing.large.h,
              AppSpacing.large.w,
              AppSpacing.medium.h,
            ),
            child: Obx(() {
              final _ = _profile.lockClock.value;
              final lockedOut = _profile.isLockedOut;
              final hint = lockedOut
                  ? _profile.lockoutLabel
                  : (_error.isEmpty ? 'Enter your 6-digit passcode' : _error);
              return Column(
                children: [
                  const CustomText(
                    'AiPlant',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    letterSpacing: -0.6,
                  ),
                  SizedBox(height: 6.h),
                  CustomText(
                    hint,
                    fontSize: 14,
                    color: (_error.isEmpty && !lockedOut)
                        ? AppColors.secondaryText
                        : AppColors.error,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.large.h),
                  PasscodeDots(length: _pin.length),
                  if (_profile.biometricOn.value && !lockedOut) ...[
                    SizedBox(height: AppSpacing.large.h),
                    GestureDetector(
                      onTap: _biometric,
                      child: Container(
                        width: 56.w,
                        height: 56.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE8F0E6),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.fingerprint_rounded,
                          size: 28.sp,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    const CustomText(
                      'Fingerprint',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                  const Spacer(),
                  PasscodePad(
                    onDigit: (value) => _digit(value),
                    onBackspace: _backspace,
                    enabled: !lockedOut,
                  ),
                ],
              );
            }),
          ), 
        ),
      ),
    );
  }
}
