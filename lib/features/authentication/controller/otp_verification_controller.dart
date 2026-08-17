import 'dart:async';

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

  final RxString email = ''.obs;
  final RxString otp = ''.obs;
  final RxBool hasError = false.obs;
  final RxInt secondsRemaining = resendSeconds.obs;

  Timer? _resendTimer;
  bool _isVerifying = false;

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
    _startResendTimer();
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

  void syncOtp(String value) {
    if (otp.value == value) return;
    otp.value = value;
    if (hasError.value) hasError.value = false;
  }

  void verifyCode() {
    if (_isVerifying || !canVerify) return;

    // Local demo comparison only. Does not contact a server.
    if (otp.value != demoOtpCode) {
      hasError.value = true;
      return;
    }

    hasError.value = false;
    _isVerifying = true;
    final navigation = NavigationHelper.toNamed(RouteNames.resetPassword);
    if (navigation == null) {
      _isVerifying = false;
      return;
    }
    navigation.whenComplete(() {
      if (isClosed) return;
      _isVerifying = false;
    });
  }

  void resendCode() {
    if (!canResend) return;
    otp.value = '';
    hasError.value = false;
    _startResendTimer();
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
      if (isClosed) {
        timer.cancel();
        return;
      }
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
    super.onClose();
  }
}
