import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/helpers/navigation_helper.dart';

class ForgotPasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxString email = ''.obs;

  bool _isSubmitting = false;

  bool get canSubmit => email.value.trim().isNotEmpty;

  void syncEmail(String value) => email.value = value;

  void submitResetRequest() {
    if (_isSubmitting) return;
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _isSubmitting = true;
    final navigation = NavigationHelper.toNamed(
      RouteNames.otpVerification,
      arguments: email.value.trim(),
    );
    if (navigation == null) {
      _isSubmitting = false;
      return;
    }
    navigation.whenComplete(() {
      if (isClosed) return;
      _isSubmitting = false;
    });
  }

  void goToLogin() {
    if (Get.key.currentState?.canPop() ?? false) {
      NavigationHelper.back();
      return;
    }
    NavigationHelper.offNamed(RouteNames.authentication);
  }
}
