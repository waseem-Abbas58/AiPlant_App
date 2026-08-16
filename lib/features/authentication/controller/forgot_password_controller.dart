import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/helpers/navigation_helper.dart';

class ForgotPasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  final RxString email = ''.obs;

  bool get canSubmit => email.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_syncEmail);
  }

  void _syncEmail() => email.value = emailController.text;

  void submitResetRequest() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    NavigationHelper.toNamed(
      RouteNames.otpVerification,
      arguments: emailController.text.trim(),
    );
  }

  void goToLogin() {
    if (Get.key.currentState?.canPop() ?? false) {
      NavigationHelper.back();
      return;
    }
    NavigationHelper.offNamed(RouteNames.authentication);
  }

  @override
  void onClose() {
    emailController
      ..removeListener(_syncEmail)
      ..dispose();
    super.onClose();
  }
}
