import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/validators/validators.dart';

class ResetPasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmFocus = FocusNode();

  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxBool isSubmitting = false.obs;

  Timer? _submitTimer;

  bool get canSubmit =>
      !isSubmitting.value &&
      Validators.password(password.value) == null &&
      Validators.confirmPassword(confirmPassword.value, password.value) ==
          null;

  @override
  void onInit() {
    super.onInit();
    passwordController.addListener(_syncPassword);
    confirmPasswordController.addListener(_syncConfirmPassword);
  }

  void _syncPassword() => password.value = passwordController.text;

  void _syncConfirmPassword() =>
      confirmPassword.value = confirmPasswordController.text;

  void submitReset() {
    if (!canSubmit) return;
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    isSubmitting.value = true;
    passwordFocus.unfocus();
    confirmFocus.unfocus();

    // Local demo only. Does not update a real account or call a backend.
    _submitTimer?.cancel();
    _submitTimer = Timer(AppDurations.medium, () {
      if (isClosed) return;
      NavigationHelper.offNamed(RouteNames.passwordResetSuccess);
    });
  }

  void goToLogin() {
    if (isSubmitting.value) return;
    NavigationHelper.offAllNamed(RouteNames.authentication);
  }

  @override
  void onClose() {
    _submitTimer?.cancel();
    passwordController
      ..removeListener(_syncPassword)
      ..dispose();
    confirmPasswordController
      ..removeListener(_syncConfirmPassword)
      ..dispose();
    passwordFocus.dispose();
    confirmFocus.dispose();
    super.onClose();
  }
}
