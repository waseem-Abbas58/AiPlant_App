import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../shared/widgets/custom_container.dart';

class AskAiFab extends StatefulWidget {
  const AskAiFab({
    super.key,
    required this.onTap,
    this.semanticsLabel = 'Ask Botanist',
  });

  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  State<AskAiFab> createState() => _AskAiFabState();
}

class _AskAiFabState extends State<AskAiFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Semantics(
        button: true,
        label: widget.semanticsLabel,
        child: CustomContainer(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          width: 44,
          height: 44,
          color: AppColors.primaryGreen,
          borderRadius: AppRadius.circular,
          shadow: AppShadows.elevated,
          alignment: Alignment.center,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }
}
