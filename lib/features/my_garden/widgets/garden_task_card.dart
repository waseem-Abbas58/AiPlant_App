import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import 'garden_plant_image.dart';

class GardenTaskCard extends StatefulWidget {
  const GardenTaskCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.plantName,
    required this.timeLabel,
    required this.done,
    required this.isAssetImage,
    required this.onToggle,
    this.onSnooze,
    this.onOpen,
    this.kind = 'water',
  });

  final String imagePath;
  final String title;
  final String plantName;
  final String timeLabel;
  final bool done;
  final bool isAssetImage;
  final VoidCallback onToggle;
  final VoidCallback? onSnooze;
  final VoidCallback? onOpen;
  final String kind;

  @override
  State<GardenTaskCard> createState() => _GardenTaskCardState();
}

class _GardenTaskCardState extends State<GardenTaskCard>
    with TickerProviderStateMixin {
  late final AnimationController _check;
  late final AnimationController _drop;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _check = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _drop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _checkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 1.18), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1), weight: 45),
    ]).animate(CurvedAnimation(parent: _check, curve: Curves.easeOutCubic));
    if (widget.done) _check.value = 1;
  }

  @override
  void didUpdateWidget(covariant GardenTaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.done == widget.done) return;
    if (widget.done) {
      HapticFeedback.lightImpact();
      _check.forward(from: 0);
      if (widget.kind == 'water') _drop.forward(from: 0);
    } else {
      _check.reverse();
    }
  }

  @override
  void dispose() {
    _check.dispose();
    _drop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: widget.onOpen ?? widget.onToggle,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.small.w + 2.w),
      child: Row(
        children: [
          Opacity(
            opacity: widget.done ? 0.55 : 1,
            child: GardenPlantImage(
              path: widget.imagePath,
              isAsset: widget.isAssetImage,
              width: 52.w,
              height: 52.w,
              borderRadius: BorderRadius.circular(AppRadius.medium.r),
            ),
          ),
          SizedBox(width: AppSpacing.small.w + 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  widget.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color:
                      widget.done ? AppColors.mutedText : AppColors.primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  '${widget.plantName} · ${widget.timeLabel}',
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          if (widget.onSnooze != null && !widget.done)
            CustomContainer(
              onTap: widget.onSnooze,
              padding: EdgeInsets.all(6.r),
              child: Icon(
                Icons.snooze_rounded,
                size: 20.sp,
                color: AppColors.mutedText,
              ),
            ),
          SizedBox(width: AppSpacing.small.w),
          SizedBox(
            width: 36.w,
            height: 36.w,
            child: CustomContainer(
              onTap: widget.onToggle,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: widget.done
                        ? _checkScale
                        : const AlwaysStoppedAnimation(1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: widget.done
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.done
                              ? AppColors.primaryGreen
                              : AppColors.border,
                          width: 1.6,
                        ),
                      ),
                      child: widget.done
                          ? Icon(
                              Icons.check_rounded,
                              size: 16.sp,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                  ),
                  if (widget.kind == 'water')
                    AnimatedBuilder(
                      animation: _drop,
                      builder: (context, child) {
                        if (_drop.value == 0) return const SizedBox.shrink();
                        return Opacity(
                          opacity: (1 - _drop.value).clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, -22.h * _drop.value),
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.water_drop_rounded,
                        size: 16.sp,
                        color: AppColors.blue,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
