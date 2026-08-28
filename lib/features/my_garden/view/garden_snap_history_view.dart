import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import '../widgets/garden_empty_state.dart';
import '../widgets/garden_snap_card.dart';
import '../widgets/garden_subpage_header.dart';

class GardenSnapHistoryView extends StatefulWidget {
  const GardenSnapHistoryView({super.key});

  @override
  State<GardenSnapHistoryView> createState() => _GardenSnapHistoryViewState();
}

class _GardenSnapHistoryViewState extends State<GardenSnapHistoryView> {
  var _wishlistTab = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyGardenController>();

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
              const GardenSubpageHeader(title: 'Collection'),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  0,
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                ),
                child: Row(
                  children: [
                    _CollectionTab(
                      label: 'Seen',
                      selected: !_wishlistTab,
                      onTap: () => setState(() => _wishlistTab = false),
                    ),
                    SizedBox(width: AppSpacing.small.w),
                    _CollectionTab(
                      label: 'Wishlist',
                      selected: _wishlistTab,
                      onTap: () => setState(() => _wishlistTab = true),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.medium.w,
                    AppSpacing.small.h,
                    AppSpacing.medium.w,
                    AppSpacing.medium.h,
                  ),
                  child: _wishlistTab
                      ? _WishlistTab(controller: controller)
                      : _SeenTab(controller: controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionTab extends StatelessWidget {
  const _CollectionTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomContainer(
        onTap: onTap,
        color: selected ? AppColors.primaryGreen : AppColors.white,
        borderRadius: AppRadius.circular,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: CustomText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.white : AppColors.primaryText,
        ),
      ),
    );
  }
}

class _SeenTab extends StatelessWidget {
  const _SeenTab({required this.controller});

  final MyGardenController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final seen = controller.seenSnaps;
      if (controller.snaps.isEmpty) {
        return GardenEmptyState(
          illustration: const GardenEmptyArt(),
          title: 'No snaps yet',
          subtitle: 'Identify a plant and it will show up here.',
          actionLabel: 'Identify Plant',
          filledAction: true,
          onAction: controller.openIdentify,
        );
      }
      if (seen.isEmpty) {
        return GardenEmptyState(
          illustration: const GardenEmptyArt(),
          title: 'All saved',
          subtitle: 'Every snap is already in your garden.',
          actionLabel: 'Identify Plant',
          onAction: controller.openIdentify,
        );
      }

      return ListView.separated(
        itemCount: seen.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.small.h),
        itemBuilder: (context, index) {
          final snap = seen[index];
          final wished = controller.isOnWishlist(snap.imagePath);
          return GardenSnapCard(
            imagePath: snap.imagePath,
            name: snap.name,
            scientificName: snap.scientificName,
            dateLabel: snap.dateLabel,
            onWishlist: wished,
            onDelete: () => controller.deleteSnap(snap),
            onAdd: () => controller.addSnapToGarden(snap),
            onOpen: () => controller.openSeenIdentify(snap),
            onSaveWishlist:
                wished ? null : () => controller.addSnapToWishlist(snap),
          );
        },
      );
    });
  }
}

class _WishlistTab extends StatelessWidget {
  const _WishlistTab({required this.controller});

  final MyGardenController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.wishlist.isEmpty) {
        return GardenEmptyState(
          illustration: const GardenEmptyArt(),
          title: 'Wishlist is empty',
          subtitle: 'Save a plant from Identify to grow later.',
          actionLabel: 'Identify Plant',
          filledAction: true,
          onAction: controller.openIdentify,
        );
      }

      return ListView.separated(
        itemCount: controller.wishlist.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.small.h),
        itemBuilder: (context, index) {
          final item = controller.wishlist[index];
          return GardenSnapCard(
            imagePath: item.imagePath,
            name: item.name,
            scientificName: item.scientificName,
            dateLabel: item.dateLabel,
            onWishlist: true,
            onDelete: () => controller.removeWishlistItem(item),
            onAdd: () => controller.saveWishlistToGarden(item),
          );
        },
      );
    });
  }
}
