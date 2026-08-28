import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_borders.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_sizes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_text.dart';
import '../widgets/auth_shared_widgets.dart';

class PasswordResetSuccessView extends StatefulWidget {
  const PasswordResetSuccessView({super.key});

  @override
  State<PasswordResetSuccessView> createState() =>
      _PasswordResetSuccessViewState();
}

class _PasswordResetSuccessViewState extends State<PasswordResetSuccessView>
    with SingleTickerProviderStateMixin {
  static final Duration _animationDuration =
      AppDurations.slow + AppDurations.slow + AppDurations.medium;
  static final Duration _holdDuration =
      AppDurations.slow + AppDurations.medium;

  late final AnimationController _controller;
  late final Animation<double> _ringFade;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringDraw;
  late final Animation<double> _checkDraw;
  late final Animation<double> _glow;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _descriptionFade;
  late final Animation<Offset> _descriptionSlide;

  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    _ringFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.20, curve: Curves.easeOutCubic),
    );
    _ringScale = Tween<double>(begin: 0.92, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.22, curve: Curves.easeOutCubic),
      ),
    );
    _ringDraw = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.52, curve: Curves.easeOutCubic),
    );
    _checkDraw = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.70, curve: Curves.easeOutCubic),
    );
    _glow = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.48, 0.78, curve: Curves.easeOutCubic),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.62, 0.82, curve: Curves.easeOutCubic),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.62, 0.82, curve: Curves.easeOutCubic),
      ),
    );
    _descriptionFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 0.94, curve: Curves.easeOutCubic),
    );
    _descriptionSlide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 0.94, curve: Curves.easeOutCubic),
      ),
    );

    _controller
      ..addStatusListener(_onAnimationStatus)
      ..forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _holdTimer?.cancel();
    _holdTimer = Timer(_holdDuration, _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    NavigationHelper.until(RouteNames.authentication);
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _controller
      ..removeStatusListener(_onAnimationStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final media = MediaQuery.of(context);
    final minHeight = media.size.height
        - media.padding.top
        - media.padding.bottom
        - AppSpacing.extraLarge.h
        - AppSpacing.large.h;
    final markSize = AppSizes.avatarXl.w + AppSpacing.medium.w;

    return PopScope(
      canPop: false,
      child: AuthScaffold(
        pinBottomDecoration: true,
        child: SizedBox(
          height: minHeight.clamp(0, media.size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _ringFade,
                child: ScaleTransition(
                  scale: _ringScale,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_ringDraw, _checkDraw, _glow]),
                    builder: (context, _) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.16 * _glow.value,
                              ),
                              blurRadius: AppSpacing.large,
                              spreadRadius: AppSpacing.extraSmall,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          size: Size.square(markSize),
                          painter: _SuccessMarkPainter(
                            ringProgress: _ringDraw.value,
                            checkProgress: _checkDraw.value,
                            color: AppColors.primaryGreen,
                            trackColor: AppColors.lightGreen.withValues(
                              alpha: 0.28,   
                            ),
                            strokeWidth: AppBorders.widthThick +
                                AppBorders.widthRegular,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.large.h),
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: CustomText(
                    'Password Updated',
                    style: textTheme.headlineSmall?.copyWith(
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w700,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.small.h),
              FadeTransition(
                opacity: _descriptionFade,
                child: SlideTransition(
                  position: _descriptionSlide,
                  child: CustomText(
                    'Your password has been updated successfully.',
                    style: textTheme.bodyMedium?.copyWith(height: 1.4),
                    color: AppColors.secondaryText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessMarkPainter extends CustomPainter {
  const _SuccessMarkPainter({
    required this.ringProgress,
    required this.checkProgress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double ringProgress;
  final double checkProgress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (ringProgress > 0) {
      final ringPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * ringProgress,
        false,
        ringPaint,
      );
    }

    if (checkProgress <= 0) return;

    final checkPath = Path()
      ..moveTo(size.width * 0.30, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.66)
      ..lineTo(size.width * 0.72, size.height * 0.36);

    final checkPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in checkPath.computeMetrics()) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * checkProgress),
        checkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessMarkPainter oldDelegate) {
    return oldDelegate.ringProgress != ringProgress ||
        oldDelegate.checkProgress != checkProgress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
