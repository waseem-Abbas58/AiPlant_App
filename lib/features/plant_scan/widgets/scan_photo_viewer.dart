import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';

class ScanPhotoItem {
  const ScanPhotoItem.file(this.path, {this.label = ''})
      : url = null,
        asset = null;

  const ScanPhotoItem.url(this.url, {this.label = ''})
      : path = null,
        asset = null;

  const ScanPhotoItem.asset(this.asset, {this.label = ''})
      : path = null,
        url = null;

  final String? path;
  final String? url;
  final String? asset;
  final String label;
}

Future<void> openScanPhotoViewer({
  required BuildContext context,
  required List<ScanPhotoItem> photos,
  int initialIndex = 0,
}) async {
  if (photos.isEmpty) return;
  final start = initialIndex.clamp(0, photos.length - 1);
  HapticFeedback.selectionClick();
  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      barrierColor: Colors.black,
      pageBuilder: (_, __, ___) => _ScanPhotoViewer(
        photos: photos,
        initialIndex: start,
      ),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

class _ScanPhotoViewer extends StatefulWidget {
  const _ScanPhotoViewer({
    required this.photos,
    required this.initialIndex,
  });

  final List<ScanPhotoItem> photos;
  final int initialIndex;

  @override
  State<_ScanPhotoViewer> createState() => _ScanPhotoViewerState();
}

class _ScanPhotoViewerState extends State<_ScanPhotoViewer> {
  late final PageController _pages;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pages = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];
    final label = photo.label.trim();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pages,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (_, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(child: _ViewerImage(widget.photos[index])),
                );
              },
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8.h,
              left: 12.w,
              child: CustomContainer(
                onTap: () => Navigator.of(context).pop(),
                width: 40,
                height: 40,
                color: AppColors.white.withValues(alpha: 0.16),
                borderRadius: AppRadius.circular,
                alignment: Alignment.center,
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                  size: 20.sp,
                ),
              ),
            ),
            if (label.isNotEmpty || widget.photos.length > 1)
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: MediaQuery.paddingOf(context).bottom + 16.h,
                child: Column(
                  children: [
                    if (label.isNotEmpty)
                      CustomText(
                        label,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        textAlign: TextAlign.center,
                      ),
                    if (widget.photos.length > 1) ...[
                      SizedBox(height: 6.h),
                      CustomText(
                        '${_index + 1} / ${widget.photos.length}',
                        fontSize: 12,
                        color: AppColors.white.withValues(alpha: 0.72),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ViewerImage extends StatelessWidget {
  const _ViewerImage(this.photo);

  final ScanPhotoItem photo;

  @override
  Widget build(BuildContext context) {
    final path = photo.path?.trim() ?? '';
    final url = photo.url?.trim() ?? '';
    final asset = photo.asset?.trim() ?? '';
    if (path.isNotEmpty) {
      return Image.file(File(path), fit: BoxFit.contain);
    }
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.broken_image_outlined,
          color: AppColors.white.withValues(alpha: 0.5),
          size: 48.sp,
        ),
      );
    }
    if (asset.isNotEmpty) {
      return Image.asset(asset, fit: BoxFit.contain);
    }
    return const SizedBox.shrink();
  }
}
