import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/helpers/navigation_helper.dart';

class AuthenticationController extends GetxController {
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  bool get canSubmit =>
      email.value.trim().isNotEmpty && password.value.isNotEmpty;

  void syncEmail(String value) => email.value = value;

  void syncPassword(String value) => password.value = value;

  void submitLogin(GlobalKey<FormState> formKey) {
    formKey.currentState?.validate();
  }

  void onForgotPassword() {
    NavigationHelper.toNamed(RouteNames.forgotPassword);
  }

  void onSignUp() {
    NavigationHelper.toNamed(RouteNames.signup);
  }

  void onGoogleLogin() {}

  void onAppleLogin() {}

  void onFacebookLogin() {}
}
