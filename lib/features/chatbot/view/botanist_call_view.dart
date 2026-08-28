import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/botanist_call_controller.dart';

class BotanistCallView extends StatefulWidget {
  const BotanistCallView({super.key});

  @override
  State<BotanistCallView> createState() => _BotanistCallViewState();
}

class _BotanistCallViewState extends State<BotanistCallView> {
  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<BotanistCallController>()) {
      Get.delete<BotanistCallController>(force: true);
    }
    Get.put(BotanistCallController());
  }

  @override
  void dispose() {
    if (Get.isRegistered<BotanistCallController>()) {
      Get.delete<BotanistCallController>(force: true);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BotanistCallController>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) controller.hangUp();
        },
        child: Scaffold(
          backgroundColor: AppColors.sageBackground,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.large.w,
                vertical: AppSpacing.medium.h,
              ),
              child: Column(
                children: [
                  CustomText(
                    controller.plantLabel,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                    textAlign: TextAlign.center,
                  ),
                  const CustomText(
                    'Voice call',
                    fontSize: 13,
                    color: AppColors.mutedText,
                  ),
                  const Spacer(),
                  const _CallOrb(),
                  SizedBox(height: AppSpacing.large.h),
                  Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: CustomText(
                        controller.caption.value,
                        key: ValueKey(controller.caption.value),
                        fontSize: 16,
                        height: 1.4,
                        color: AppColors.secondaryText,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const _CallActions(),
                  SizedBox(height: AppSpacing.large.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CallOrb extends StatefulWidget {
  const _CallOrb();

  @override
  State<_CallOrb> createState() => _CallOrbState();
}

class _CallOrbState extends State<_CallOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BotanistCallController>();
    final size = 200.r;
    return Obx(() {
      final live = controller.listening.value || controller.speaking.value;
      return AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          final scale = live ? 0.96 + (_pulse.value * 0.08) : 1.0;
          final glow = live ? 0.16 + (_pulse.value * 0.14) : 0.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1.12 + (_pulse.value * 0.06),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.blue.withValues(alpha: glow),
                  ),
                ),
              ),
              Transform.scale(scale: scale, child: child),
            ],
          );
        },
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFFB3E5FC),
                AppColors.blue,
                AppColors.primaryGreen,
              ],
              stops: [0.12, 0.62, 1],
            ),
            boxShadow: AppShadows.elevated,
          ),
          child: Icon(
            Icons.graphic_eq_rounded,
            size: 64.sp,
            color: AppColors.white,
          ),
        ),
      );
    });
  }
}

class _CallActions extends GetView<BotanistCallController> {
  const _CallActions();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final muted = controller.muted.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomContainer(
            onTap: () {
              HapticFeedback.selectionClick();
              controller.toggleMute();
            },
            width: 64,
            height: 64,
            color: muted ? AppColors.error : AppColors.white,
            borderRadius: AppRadius.circular,
            shadow: AppShadows.soft,
            alignment: Alignment.center,
            child: Icon(
              muted ? Icons.mic_off_rounded : Icons.mic_none_rounded,
              size: 28.sp,
              color: muted ? AppColors.white : AppColors.primaryText,
            ),
          ),
          SizedBox(width: AppSpacing.extraLarge.w),
          CustomContainer(
            onTap: () {
              HapticFeedback.mediumImpact();
              controller.hangUp();
            },
            width: 72,
            height: 72,
            color: AppColors.white,
            borderRadius: AppRadius.circular,
            shadow: AppShadows.medium,
            alignment: Alignment.center,
            child: Icon(
              Icons.close_rounded,
              size: 32.sp,
              color: AppColors.primaryText,
            ),
          ),
        ],
      );
    });
  }
}

void openBotanistCall() {
  NavigationHelper.to(
    () => const BotanistCallView(),
    fullscreenDialog: true,
    transition: Transition.fadeIn,
  );
}
