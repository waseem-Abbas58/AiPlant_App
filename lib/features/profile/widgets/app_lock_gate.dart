import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/profile_controller.dart';
import '../view/app_lock_view.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Get.isRegistered<ProfileController>()) return;
    final profile = Get.find<ProfileController>();
    if (state == AppLifecycleState.paused) {
      profile.noteBackgrounded();
    } else if (state == AppLifecycleState.resumed) {
      profile.lockIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) return widget.child;
    return Obx(() {
      final locked = Get.find<ProfileController>().appLocked.value;
      return Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (locked) const AppLockView(),
        ],
      );
    });
  }
}
