import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/permission_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';

class AppPermissionsView extends StatefulWidget {
  const AppPermissionsView({super.key});

  @override
  State<AppPermissionsView> createState() => _AppPermissionsViewState();
}

class _AppPermissionsViewState extends State<AppPermissionsView> {
  static const _items = [
    (
      AppPermission.camera,
      Icons.photo_camera_outlined,
      'Camera',
      'Identify plants and add them to your garden',
    ),
    (
      AppPermission.photos,
      Icons.photo_outlined,
      'Photos',
      'Choose a plant or profile picture from the gallery',
    ),
    (
      AppPermission.microphone,
      Icons.mic_none_rounded,
      'Microphone',
      'Talk to Ask Botanist with voice',
    ),
    (
      AppPermission.notifications,
      Icons.notifications_outlined,
      'Notifications',
      'Care reminders, plan, and botanist alerts',
    ),
  ];

  final _status = <AppPermission, PermissionStatus>{};
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final next = <AppPermission, PermissionStatus>{};
    for (final item in _items) {
      next[item.$1] = await PermissionHelper.check(item.$1);
    }
    if (!mounted) return;
    setState(() {
      _status
        ..clear()
        ..addAll(next);
      _loading = false;
    });
  }

  Future<void> _tap(AppPermission permission) async {
    HapticFeedback.selectionClick();
    final current = _status[permission];
    if (current?.isPermanentlyDenied == true) {
      await PermissionHelper.openSettings();
      await _refresh();
      return;
    }
    await PermissionHelper.request(permission);
    await _refresh();
  }

  String _label(PermissionStatus? status) {
    if (status == null) return '…';
    if (status.isGranted || status.isLimited) return 'On';
    return 'Off';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          child: Column(
            children: [
              const GardenSubpageHeader(title: 'App permissions'),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.large.h,
                  ),
                  children: [
                    const GardenPopIn(
                      child: CustomText(
                        'These are needed for scan, garden photos, voice, and care alerts. You can turn them off in system settings.',
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: AppSpacing.medium.h),
                    GardenPopIn(
                      delay: const Duration(milliseconds: 40),
                      child: CustomContainer(
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        border: Border.all(color: AppColors.border),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.medium.w,
                          vertical: 4.h,
                        ),
                        child: _loading
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.h),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  for (var i = 0; i < _items.length; i++) ...[
                                    if (i > 0)
                                      Divider(
                                        height: 1,
                                        color: AppColors.border
                                            .withValues(alpha: 0.7),
                                      ),
                                    _PermissionRow(
                                      icon: _items[i].$2,
                                      title: _items[i].$3,
                                      subtitle: _items[i].$4,
                                      status: _label(_status[_items[i].$1]),
                                      onTap: () => _tap(_items[i].$1),
                                    ),
                                  ],
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final on = status == 'On';
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F0E6),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18.sp, color: AppColors.primaryGreen),
          ),
          SizedBox(width: AppSpacing.small.w + 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  subtitle,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          CustomText(
            status,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: on ? AppColors.primaryGreen : AppColors.mutedText,
          ),
        ],
      ),
    );
  }
}
