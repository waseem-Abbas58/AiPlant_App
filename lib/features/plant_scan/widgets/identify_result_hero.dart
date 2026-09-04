import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'scan_photo_viewer.dart';

class IdentifyResultHero extends StatelessWidget {
  const IdentifyResultHero({
    super.key,
    required this.path,
    this.referenceUrls = const [],
    this.fallbackAsset,
  });

  final String path;
  final List<String> referenceUrls;
  final String? fallbackAsset;

  static const _heroH = 228.0;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final urls = referenceUrls
        .map((url) => url.trim())
        .where((url) => url.startsWith('http'))
        .take(6)
        .toList();
    final asset = fallbackAsset?.trim() ?? '';
    final hasRefs = urls.isNotEmpty || asset.isNotEmpty;
    final album = <ScanPhotoItem>[
      ScanPhotoItem.file(path, label: 'Your photo'),
      ...urls.map((url) => ScanPhotoItem.url(url, label: 'Reference')),
      if (urls.isEmpty && asset.isNotEmpty)
        ScanPhotoItem.asset(asset, label: 'Reference'),
    ];

    void openAt(int index) {
      openScanPhotoViewer(
        context: context,
        photos: album,
        initialIndex: index,
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        top + 8.h,
        AppSpacing.medium.w,
        0,
      ),
      child: SizedBox(
        height: _heroH.h,
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  flex: hasRefs ? 5 : 1,
                  child: _PhotoFrame(
                    label: 'Your photo',
                    onTap: () => openAt(0),
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: AppColors.divider),
                    ),
                  ),
                ),
                if (hasRefs) ...[
                  SizedBox(width: AppSpacing.small.w),
                  Expanded(
                    flex: 5,
                    child: urls.length <= 1
                        ? _PhotoFrame(
                            label: 'Reference',
                            onTap: () => openAt(1),
                            child: urls.isNotEmpty
                                ? _NetPhoto(urls.first)
                                : Image.asset(
                                    asset,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, __, ___) =>
                                        const ColoredBox(
                                      color: AppColors.divider,
                                    ),
                                  ),
                          )
                        : _ReferenceGrid(
                            urls: urls,
                            onOpen: (index) => openAt(index + 1),
                          ),
                  ),
                ],
              ],
            ),
            Positioned(
              top: 10.h,
              left: 10.w,
              child: CustomContainer(
                onTap: NavigationHelper.back,
                width: 36,
                height: 36,
                color: AppColors.white,
                borderRadius: AppRadius.circular,
                shadow: AppShadows.soft,
                alignment: Alignment.center,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16.sp,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceGrid extends StatelessWidget {
  const _ReferenceGrid({required this.urls, required this.onOpen});

  final List<String> urls;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final tiles = urls.take(6).toList();
    return CustomContainer(
      color: AppColors.sageBackground,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.diffused,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(4.w),
      child: Stack(
        fit: StackFit.expand,
        children: [
          GridView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.horizontal,
            physics: tiles.length > 4
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 4.w,
              crossAxisSpacing: 4.h,
              childAspectRatio: 1,
            ),
            itemCount: tiles.length,
            itemBuilder: (_, index) => GestureDetector(
              onTap: () => onOpen(index),
              child: _NetPhoto(tiles[index], radius: 10),
            ),
          ),
          Positioned(
            left: 6.w,
            bottom: 6.h,
            child: CustomContainer(
              color: AppColors.white.withValues(alpha: 0.92),
              borderRadius: AppRadius.circular,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: const CustomText(
                'Reference',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({
    required this.label,
    required this.child,
    this.onTap,
  });

  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.sageBackground,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.diffused,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            left: 8.w,
            bottom: 8.h,
            child: CustomContainer(
              color: AppColors.white.withValues(alpha: 0.92),
              borderRadius: AppRadius.circular,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: CustomText(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetPhoto extends StatelessWidget {
  const _NetPhoto(this.url, {this.radius = 0});

  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const ColoredBox(color: AppColors.divider),
    );
    if (radius <= 0) return image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: image,
    );
  }
}
