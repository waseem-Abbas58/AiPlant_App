import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../core/constants/app_durations.dart';
import '../../../shared/widgets/custom_text.dart';

class WaterLevelGauge extends StatefulWidget {
  const WaterLevelGauge({
    super.key,
    required this.level,
    this.size = 220,
    this.color,
    this.centerLabel,
    this.centerSub,
  });

  final double level;
  final double size;
  final Color? color;
  final String? centerLabel;
  final String? centerSub;

  @override
  State<WaterLevelGauge> createState() => _WaterLevelGaugeState();
}

class _WaterLevelGaugeState extends State<WaterLevelGauge>
    with TickerProviderStateMixin {
  late final AnimationController _wave;
  late final AnimationController _fill;
  late final AnimationController _burst;
  late Animation<double> _level;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _fill = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );
    _burst = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );
    _level = Tween<double>(
      begin: 0,
      end: widget.level.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _fill, curve: Curves.easeOutCubic));
    _fill.forward();
  }

  @override
  void didUpdateWidget(WaterLevelGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.level == widget.level) return;
    final next = widget.level.clamp(0.0, 1.0);
    if (next > oldWidget.level + 0.15) {
      _burst.forward(from: 0);
    }
    _level = Tween<double>(
      begin: _level.value,
      end: next,
    ).animate(CurvedAnimation(parent: _fill, curve: Curves.easeOutCubic));
    _fill
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _wave.dispose();
    _fill.dispose();
    _burst.dispose();
    super.dispose();
  }

  Color get _waterColor {
    final t = widget.level.clamp(0.0, 1.0);
    return widget.color ??
        Color.lerp(AppColors.warning, AppColors.blue, t) ??
        AppColors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size.w;

    return AnimatedBuilder(
      animation: Listenable.merge([_wave, _fill, _burst]),
      builder: (context, _) {
        final fill = _level.value;
        final burst = Curves.easeOut.transform(_burst.value);
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE7EEF2),
                  boxShadow: AppShadows.diffused,
                  border: Border.all(color: AppColors.white, width: 8.w),
                ),
                child: ClipOval(
                  child: CustomPaint(
                    painter: _WavePainter(
                      fill: 0.12 + fill.clamp(0.0, 1.0) * 0.74,
                      phase: _wave.value * math.pi * 2,
                      color: _waterColor,
                    ),
                  ),
                ),
              ),
              if (widget.centerLabel != null)
                _GaugeReadout(
                  label: widget.centerLabel!,
                  sub: widget.centerSub,
                  onWater: fill > 0.42,
                ),
              if (_burst.isAnimating || _burst.value > 0)
                ..._droplets(size, burst),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _droplets(double size, double burst) {
    const spots = <Offset>[
      Offset(-0.28, -0.42),
      Offset(0.02, -0.55),
      Offset(0.3, -0.38),
    ];
    return [
      for (var i = 0; i < spots.length; i++)
        Transform.translate(
          offset: Offset(
            spots[i].dx * size,
            spots[i].dy * size - 18.h * burst,
          ),
          child: Opacity(
            opacity: (1 - burst).clamp(0.0, 1.0),
            child: Icon(
              Icons.water_drop_rounded,
              size: (16 + i * 3).sp,
              color: AppColors.blue.withValues(alpha: 0.85),
            ),
          ),
        ),
    ];
  }
}

class _GaugeReadout extends StatelessWidget {
  const _GaugeReadout({
    required this.label,
    required this.onWater,
    this.sub,
  });

  final String label;
  final String? sub;
  final bool onWater;

  @override
  Widget build(BuildContext context) {
    final color = onWater ? AppColors.white : AppColors.primaryText;
    final muted = onWater
        ? AppColors.white.withValues(alpha: 0.86)
        : AppColors.secondaryText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          label,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: -0.6,
        ),
        if (sub != null)
          CustomText(
            sub!,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter({
    required this.fill,
    required this.phase,
    required this.color,
  });

  final double fill;
  final double phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (fill <= 0.01) return;
    final h = size.height;
    final w = size.width;
    final surface = h * (1 - fill.clamp(0.02, 1));
    final amp = (7.0 + fill * 3).clamp(6.0, 11.0);

    void drawWave(double offset, double alpha, double extraAmp) {
      final path = Path()
        ..moveTo(0, h)
        ..lineTo(0, surface);
      for (var x = 0.0; x <= w; x += 2) {
        final y = surface +
            math.sin((x / w) * math.pi * 2 + phase + offset) *
                (amp + extraAmp);
        path.lineTo(x, y);
      }
      path
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }

    drawWave(0.6, 0.38, 3);
    drawWave(0, 0.92, 0);

    final shine = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.white.withValues(alpha: 0.22),
          AppColors.white.withValues(alpha: 0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(Offset(w * 0.35, h * 0.32), w * 0.22, shine);
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.fill != fill || old.phase != phase || old.color != color;
}
