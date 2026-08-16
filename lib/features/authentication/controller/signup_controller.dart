import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/helpers/navigation_helper.dart';

class SignupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;

  bool get canSubmit =>
      name.value.trim().isNotEmpty &&
      email.value.trim().isNotEmpty &&
      password.value.isNotEmpty &&
      confirmPassword.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_syncName);
    emailController.addListener(_syncEmail);
    passwordController.addListener(_syncPassword);
    confirmPasswordController.addListener(_syncConfirmPassword);
  }

  void _syncName() => name.value = nameController.text;
  void _syncEmail() => email.value = emailController.text;
  void _syncPassword() => password.value = passwordController.text;
  void _syncConfirmPassword() =>
      confirmPassword.value = confirmPasswordController.text;

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

  @override
  void onClose() {
    nameController
      ..removeListener(_syncName)
      ..dispose();
    emailController
      ..removeListener(_syncEmail)
      ..dispose();
    passwordController
      ..removeListener(_syncPassword)
      ..dispose();
    confirmPasswordController
      ..removeListener(_syncConfirmPassword)
      ..dispose();
    super.onClose();
  }
}
