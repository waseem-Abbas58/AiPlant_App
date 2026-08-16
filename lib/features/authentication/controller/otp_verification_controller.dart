import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/helpers/navigation_helper.dart';

class OtpVerificationController extends GetxController {
  static const int otpLength = 6;
  static const int resendSeconds = 45;

  /// TEMPORARY UI-ONLY DEMO CODE.
  /// Compared locally in this controller. Not generated, sent, or verified
  /// by a server, Firebase, or API.
  static const String demoOtpCode = '123456';

  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  final RxString email = ''.obs;
  final RxString otp = ''.obs;
  final RxBool hasError = false.obs;
  final RxInt secondsRemaining = resendSeconds.obs;

  Timer? _resendTimer;

  String get maskedEmail => _maskEmail(email.value);

  bool get canVerify => otp.value.length == otpLength;

  bool get canResend => secondsRemaining.value == 0;

  String get resendLabel {
    if (canResend) return 'Resend code';
    final minutes = (secondsRemaining.value ~/ 60).toString().padLeft(2, '0');
    final secs = (secondsRemaining.value % 60).toString().padLeft(2, '0');
    return 'Resend code in $minutes:$secs';
  }

  @override
  void onInit() {
    super.onInit();
    email.value = _readEmailArgument();
    otpController.addListener(_syncOtp);
    _startResendTimer();
  }

  @override
  void onReady() {
    super.onReady();
    otpFocusNode.requestFocus();
  }

  String _readEmailArgument() {
    final args = Get.arguments;
    if (args is String && args.trim().isNotEmpty) {
      return args.trim();
    }
    if (args is Map) {
      final value = args['email'];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  String _maskEmail(String value) {
    final at = value.indexOf('@');
    if (at <= 0) return value;
    final local = value.substring(0, at);
    final domain = value.substring(at);
    final visible = local.length >= 2 ? local.substring(0, 2) : local;
    return '$visible••••$domain';
  }

  void _syncOtp() {
    final digits = otpController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final clipped = digits.length > otpLength
        ? digits.substring(0, otpLength)
        : digits;
    if (clipped != otpController.text) {
      otpController.value = TextEditingValue(
        text: clipped,
        selection: TextSelection.collapsed(offset: clipped.length),
      );
      return;
    }
    if (otp.value == clipped) return;
    otp.value = clipped;
    if (hasError.value) hasError.value = false;
  }

  void verifyCode() {
    if (!canVerify) return;
    otpFocusNode.unfocus();

    // Local demo comparison only. Does not contact a server.
    if (otp.value == demoOtpCode) {
      hasError.value = false;
      NavigationHelper.toNamed(RouteNames.resetPassword);
      return;
    }

    hasError.value = true;
  }

  void resendCode() {
    if (!canResend) return;
    otpController.clear();
    otp.value = '';
    hasError.value = false;
    _startResendTimer();
    otpFocusNode.requestFocus();
  }

  void goToForgotPassword() {
    if (Get.key.currentState?.canPop() ?? false) {
      NavigationHelper.back();
      return;
    }
    NavigationHelper.offNamed(RouteNames.forgotPassword);
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    secondsRemaining.value = resendSeconds;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value <= 1) {
        secondsRemaining.value = 0;
        timer.cancel();
        return;
      }
      secondsRemaining.value--;
    });
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    otpController
      ..removeListener(_syncOtp)
      ..dispose();
    otpFocusNode.dispose();
    super.onClose();
  }
}
