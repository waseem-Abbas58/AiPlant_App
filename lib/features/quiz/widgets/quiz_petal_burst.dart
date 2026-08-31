import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class QuizPetalBurst extends StatefulWidget {
  const QuizPetalBurst({super.key});

  @override
  State<QuizPetalBurst> createState() => _QuizPetalBurstState();
}

class _QuizPetalBurstState extends State<QuizPetalBurst>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2800);

  late final AnimationController _controller;
  late final List<_Petal> _petals;

  @override
  void initState() {
    super.initState();
    _petals = _Petal.burst();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isCompleted) return const SizedBox.shrink();

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          if (size.isEmpty) return const SizedBox.shrink();
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.isCompleted) return const SizedBox.shrink();
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final petal in _petals)
                    petal.build(size, _controller.value),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

enum _Origin { top, left, right }

class _Petal {
  const _Petal({
    required this.origin,
    required this.along,
    required this.delay,
    required this.size,
    required this.spin,
    required this.sway,
    required this.color,
    required this.icon,
  });

  final _Origin origin;
  final double along;
  final double delay;
  final double size;
  final double spin;
  final double sway;
  final Color color;
  final IconData icon;

  static const _icons = [
    Icons.eco_rounded,
    Icons.spa_rounded,
    Icons.filter_vintage_rounded,
    Icons.local_florist_rounded,
  ];

  static const _colors = [
    AppColors.primaryGreen,
    AppColors.lightGreen,
    AppColors.secondaryGreen,
    Color(0xFFC4785A),
    Color(0xFFE8A0A8),
  ];

  static List<_Petal> burst() {
    final random = math.Random();
    return [
      for (var i = 0; i < 10; i++)
        _Petal._random(random, _Origin.top, i / 10),
      for (var i = 0; i < 7; i++)
        _Petal._random(random, _Origin.left, i / 7),
      for (var i = 0; i < 7; i++)
        _Petal._random(random, _Origin.right, i / 7),
    ];
  }

  factory _Petal._random(math.Random random, _Origin origin, double along) {
    final sideAlong = origin == _Origin.top
        ? (along < 0.5
            ? along * 0.42
            : 0.58 + (along - 0.5) * 0.84)
        : along;
    return _Petal(
      origin: origin,
      along: (sideAlong + random.nextDouble() * 0.06).clamp(0.02, 0.98),
      delay: random.nextDouble() * 0.28,
      size: 14 + random.nextDouble() * 12,
      spin: (random.nextDouble() - 0.5) * 4.6,
      sway: 14 + random.nextDouble() * 22,
      color: _colors[random.nextInt(_colors.length)],
      icon: _icons[random.nextInt(_icons.length)],
    );
  }

  Widget build(Size screen, double raw) {
    final t = ((raw - delay) / (1 - delay)).clamp(0.0, 1.0);
    if (t <= 0) return const SizedBox.shrink();

    final fadeIn = Curves.easeOut.transform((t / 0.1).clamp(0.0, 1.0));
    final fadeOut = t < 0.55
        ? 1.0
        : Curves.easeIn.transform(1 - ((t - 0.55) / 0.45).clamp(0.0, 1.0));
    final opacity = fadeIn * fadeOut * 0.85;
    if (opacity <= 0.01) return const SizedBox.shrink();

    final swayX = math.sin(t * math.pi * 2.2) * sway;
    late final double x;
    late final double y;
    switch (origin) {
      case _Origin.top:
        x = screen.width * along + swayX;
        y = -24 + t * (screen.height + 48);
      case _Origin.left:
        x = -20 + t * (screen.width * 0.55) + swayX * 0.35;
        y = screen.height * (0.22 + along * 0.7) + t * screen.height * 0.35;
      case _Origin.right:
        x = screen.width + 20 - t * (screen.width * 0.55) + swayX * 0.35;
        y = screen.height * (0.22 + along * 0.7) + t * screen.height * 0.35;
    }

    return Positioned(
      left: x - size / 2,
      top: y - size / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: t * spin,
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}
