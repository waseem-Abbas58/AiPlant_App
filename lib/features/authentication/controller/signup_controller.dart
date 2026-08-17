import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/helpers/navigation_helper.dart';

class SignupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  bool get canSubmit =>
      name.value.trim().isNotEmpty &&
      email.value.trim().isNotEmpty &&
      password.value.isNotEmpty;

  void syncName(String value) => name.value = value;

  void syncEmail(String value) => email.value = value;

  void syncPassword(String value) => password.value = value;

  void submitSignup() {
    formKey.currentState?.validate();
  }

  void goToLogin() {
    if (Get.key.currentState?.canPop() ?? false) {
      NavigationHelper.back();
      return;
    }
    NavigationHelper.offNamed(RouteNames.authentication);
  }

  void onGoogleSignup() {}

  void onAppleSignup() {}

  void onFacebookSignup() {}
}
