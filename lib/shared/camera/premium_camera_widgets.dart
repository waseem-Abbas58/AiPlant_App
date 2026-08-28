import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../widgets/custom_container.dart';
import '../widgets/custom_text.dart';
import 'camera_light_mode.dart';
import 'premium_camera_session.dart';

class CameraControlDock extends StatelessWidget {
  const CameraControlDock({
    super.key,
    required this.child,
    this.extraBottom = 0,
    this.frosted = true,
  });

  final Widget child;
  final double extraBottom;
  final bool frosted;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + extraBottom;
    final padding = EdgeInsets.fromLTRB(
      AppSpacing.medium.w,
      AppSpacing.medium.h,
      AppSpacing.medium.w,
      AppSpacing.medium.h + bottom,
    );
    if (!frosted) {
      return Padding(padding: padding, child: child);
    }
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.16),
                Colors.black.withValues(alpha: 0.46),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.14),
              ),
            ),
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class CameraPreviewGestures extends StatelessWidget {
  const CameraPreviewGestures({
    super.key,
    required this.camera,
    required this.session,
    required this.onChanged,
    required this.child,
  });

  final CameraController camera;
  final PremiumCameraSession session;
  final VoidCallback onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) async {
            await session.focusAt(camera, details.localPosition, area);
            onChanged();
          },
          onScaleStart: (_) => session.beginPinch(),
          onScaleUpdate: (details) async {
            if (details.pointerCount >= 2) {
              await session.updatePinch(camera, details.scale);
            } else {
              await session.nudgeZoom(camera, details.focalPointDelta.dy);
            }
            onChanged();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              child,
              if (session.showFocus && session.focusLocal != null)
                CameraFocusRing(offset: session.focusLocal!),
            ],
          ),
        );
      },
    );
  }
}

class CameraFocusRing extends StatelessWidget {
  const CameraFocusRing({super.key, required this.offset});

  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx - 36.w,
      top: offset.dy - 36.w,
      child: IgnorePointer(
        child: SizedBox(
          width: 72.w,
          height: 72.w,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}

class CameraFlashButton extends StatelessWidget {
  const CameraFlashButton({
    super.key,
    required this.mode,
    required this.onTap,
  });

  final CameraLightMode mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: Colors.black.withValues(alpha: 0.38),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(mode.icon, color: AppColors.white, size: 18.sp),
          SizedBox(width: 4.w),
          CustomText(
            mode.label,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}

class CameraLowLightHint extends StatelessWidget {
  const CameraLowLightHint({
    super.key,
    required this.onTurnOn,
    required this.onDismiss,
  });

  final VoidCallback onTurnOn;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: Colors.black.withValues(alpha: 0.62),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 6.w, 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_twilight_rounded, color: AppColors.white, size: 16.sp),
          SizedBox(width: 8.w),
          CustomContainer(
            onTap: onTurnOn,
            child: const CustomText(
              'Too dark? Turn on flash',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          CustomContainer(
            onTap: onDismiss,
            padding: EdgeInsets.all(4.w),
            child: Icon(Icons.close_rounded, color: AppColors.white, size: 16.sp),
          ),
        ],
      ),
    );
  }
}

class CameraGuideHint extends StatelessWidget {
  const CameraGuideHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: Colors.black.withValues(alpha: 0.48),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: CustomText(
        text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class CameraZoomRail extends StatelessWidget {
  const CameraZoomRail({
    super.key,
    required this.zoom,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double zoom;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  static const double _barH = 78;
  static const double _thumb = 16;

  @override
  Widget build(BuildContext context) {
    final range = (max - min).clamp(0.0, 20.0);
    final t = range < 0.05
        ? 0.0
        : ((zoom - min) / range).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (range < 0.05) return;
        onChanged(zoom - details.delta.dy * range / _barH.h);
      },
      child: SizedBox(
        width: 28.w,
        height: _barH.h,
        child: CustomPaint(
          painter: _TaperZoomPainter(t: t, thumb: _thumb.w),
        ),
      ),
    );
  }
}

class _TaperZoomPainter extends CustomPainter {
  const _TaperZoomPainter({required this.t, required this.thumb});

  final double t;
  final double thumb;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final r = thumb / 2;
    final top = 5.0;
    final bottom = size.height - r;
    const topHalf = 6.5;
    const botHalf = 1.15;

    final fill = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path()
      ..moveTo(cx - topHalf, top + topHalf)
      ..arcToPoint(
        Offset(cx + topHalf, top + topHalf),
        radius: const Radius.circular(topHalf),
        clockwise: false,
      )
      ..lineTo(cx + botHalf, bottom)
      ..lineTo(cx - botHalf, bottom)
      ..close();
    canvas.drawPath(path, fill);

    final y = bottom - t * (bottom - top - topHalf);
    canvas.drawCircle(Offset(cx, y), r, fill);
  }

  @override
  bool shouldRepaint(covariant _TaperZoomPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.thumb != thumb;
}

class CameraZoomChip extends StatelessWidget {
  const CameraZoomChip({
    super.key,
    required this.zoom,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double zoom;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final canZoom = max > min + 0.05;
    final label = zoom < min + 0.15
        ? '1.0x'
        : '${zoom.toStringAsFixed(1)}x';
    return CustomContainer(
      onTap: canZoom
          ? () {
              final boosted = (min + 1).clamp(min, max);
              final next = zoom < min + 0.35 ? boosted : min;
              onChanged(next);
            }
          : null,
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: CustomText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
    );
  }
}

class CameraZoomLabel extends StatelessWidget {
  const CameraZoomLabel({super.key, required this.zoom});

  final double zoom;

  @override
  Widget build(BuildContext context) {
    if (zoom < 1.08) return const SizedBox.shrink();
    return CustomContainer(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: CustomText(
        '${zoom.toStringAsFixed(1)}x',
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      ),
    );
  }
}

class CameraFrameGuideToggle extends StatelessWidget {
  const CameraFrameGuideToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final CameraFrameGuide value;
  final ValueChanged<CameraFrameGuide> onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.all(4.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in CameraFrameGuide.values)
            CustomContainer(
              onTap: () => onChanged(item),
              color: value == item ? AppColors.white : Colors.transparent,
              borderRadius: AppRadius.circular,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              child: CustomText(
                item.chip,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: value == item ? AppColors.primaryText : AppColors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class CameraShutterButton extends StatelessWidget {
  const CameraShutterButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: CustomContainer(
        width: 78,
        height: 78,
        color: AppColors.white.withValues(alpha: 0.18),
        borderRadius: AppRadius.circular,
        border: Border.all(color: AppColors.white, width: 3),
        alignment: Alignment.center,
        child: CustomContainer(
          width: 62,
          height: 62,
          color: AppColors.white,
          borderRadius: AppRadius.circular,
        ),
      ),
    );
  }
}

class CameraShutterFlash extends StatelessWidget {
  const CameraShutterFlash({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 0.72 : 0,
        duration: const Duration(milliseconds: 90),
        child: const ColoredBox(color: AppColors.white),
      ),
    );
  }
}
