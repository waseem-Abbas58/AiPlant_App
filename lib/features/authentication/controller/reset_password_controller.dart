import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/route_names.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/validators/validators.dart';

class ResetPasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxBool isSubmitting = false.obs;

  Timer? _submitTimer;

  bool get canSubmit =>
      !isSubmitting.value &&
      Validators.password(password.value) == null &&
      Validators.confirmPassword(confirmPassword.value, password.value) ==
          null;

  void syncPassword(String value) => password.value = value;

  void syncConfirmPassword(String value) => confirmPassword.value = value;

  void submitReset() {
    if (!canSubmit) return;
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    isSubmitting.value = true;

    // Local demo only. Does not update a real account or call a backend.
    _submitTimer?.cancel();
    _submitTimer = Timer(AppDurations.medium, () {
      if (isClosed) return;
      NavigationHelper.offNamed(RouteNames.passwordResetSuccess);
    });
  }

  void goToLogin() {
    if (isSubmitting.value) return;
    NavigationHelper.until(RouteNames.authentication);
  }

  @override
  void onClose() {
    _submitTimer?.cancel();
    super.onClose();
  }
}
