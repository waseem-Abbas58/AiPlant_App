import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/my_garden_controller.dart';
import '../widgets/garden_empty_state.dart';
import '../widgets/garden_snap_card.dart';
import '../widgets/garden_subpage_header.dart';

class GardenSnapHistoryView extends StatelessWidget {
  const GardenSnapHistoryView({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyGardenController>();
    final body = Column(
      children: [
        if (!embedded) const GardenSubpageHeader(title: 'Collection'),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.medium.w,
            embedded ? AppSpacing.small.h : 0,
            AppSpacing.medium.w,
            AppSpacing.small.h,
          ),
          child: Obx(() {
            final wishlistTab = controller.snapCollectionTab.value == 1;
            return CustomContainer(
              color: AppColors.white,
              borderRadius: AppRadius.large,
              shadow: AppShadows.soft,
              clipBehavior: Clip.antiAlias,
              padding: EdgeInsets.all(4.r),
              child: Row(
                children: [
                  _CollectionTab(
                    label: 'Seen',
                    selected: !wishlistTab,
                    onTap: () => controller.snapCollectionTab.value = 0,
                  ),
                  _CollectionTab(
                    label: 'Wishlist',
                    selected: wishlistTab,
                    onTap: () => controller.snapCollectionTab.value = 1,
                  ),
                ],
              ),
            );
          }),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.medium.w,
              AppSpacing.small.h,
              AppSpacing.medium.w,
              embedded ? 0 : AppSpacing.medium.h,
            ),
            child: Obx(() {
              final wishlistTab = controller.snapCollectionTab.value == 1;
              return wishlistTab
                  ? _WishlistTab(controller: controller)
                  : _SeenTab(controller: controller);
            }),
          ),
        ),
      ],
    );

    if (embedded) return body;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(child: body),
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
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        color: selected ? AppColors.primaryGreen : Colors.transparent,
        borderRadius: AppRadius.medium,
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
      final snaps = controller.snaps;
      if (snaps.isEmpty) {
        return GardenEmptyState(
          illustration: const GardenSnapEmptyArt(),
          title: 'No snaps yet',
          subtitle: 'Identify a plant and it will show up here.',
          actionLabel: 'Identify Plant',
          onAction: controller.openIdentify,
        );
      }

      return ListView.separated(
        itemCount: snaps.length,
        separatorBuilder: (_, __) => SizedBox(height: AppSpacing.small.h),
        itemBuilder: (context, index) {
          final snap = snaps[index];
          final inGarden = controller.isInGarden(snap.imagePath);
          final wished = controller.isOnWishlist(snap.imagePath);
          return GardenSnapCard(
            imagePath: snap.imagePath,
            name: snap.name,
            scientificName: snap.scientificName,
            dateLabel: snap.dateLabel,
            inGarden: inGarden,
            onWishlist: wished,
            onDelete: () => controller.deleteSnap(snap),
            onAdd: inGarden ? null : () => controller.addSnapToGarden(snap),
            onOpen: () => controller.openSeenIdentify(snap),
            onSaveWishlist:
                wished || inGarden ? null : () => controller.addSnapToWishlist(snap),
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
          illustration: const GardenSnapEmptyArt(),
          title: 'Wishlist is empty',
          subtitle: 'Save a plant from Identify to grow later.',
          actionLabel: 'Identify Plant',
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
