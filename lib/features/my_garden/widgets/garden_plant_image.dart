import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class GardenPlantImage extends StatelessWidget {
  const GardenPlantImage({
    super.key,
    required this.path,
    required this.isAsset,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.topCenter,
    this.borderRadius,
  });

  final String path;
  final bool isAsset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = isAsset
        ? Image.asset(
            path,
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            errorBuilder: (_, __, ___) => _fallback(width, height),
          )
        : Image(
            image: FileImage(File(path)),
            width: width,
            height: height,
            fit: fit,
            alignment: alignment,
            key: ValueKey(path),
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _fallback(width, height),
          );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }

  static Widget _fallback(double? width, double? height) {
    return ColoredBox(
      color: AppColors.sageBackground,
      child: SizedBox(
        width: width,
        height: height,
        child: const Icon(
          Icons.local_florist_outlined,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}
