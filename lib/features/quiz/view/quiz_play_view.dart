import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/routes/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_durations.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../chatbot/controller/chatbot_controller.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../home/controller/home_controller.dart';
import '../model/weekly_quiz.dart';
import '../widgets/quiz_petal_burst.dart';

class QuizPlayView extends StatefulWidget {
  const QuizPlayView({super.key});

  @override
  State<QuizPlayView> createState() => _QuizPlayViewState();
}

class _QuizPlayViewState extends State<QuizPlayView> {
  static const _letters = ['A', 'B', 'C', 'D'];

  int _index = 0;
  int? _selected;
  int _score = 0;
  bool _finished = false;

  QuizQuestion get _question => WeeklyQuiz.questions[_index];

  int get _total => WeeklyQuiz.questions.length;

  bool get _isLast => _index == _total - 1;

  void _pick(int optionIndex) {
    if (_selected != null) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selected = optionIndex;
      if (optionIndex == _question.correctIndex) _score++;
    });
  }

  void _next() {
    if (_selected == null) return;
    HapticFeedback.selectionClick();
    if (_isLast) {
      final perfect = _score == _total;
      setState(() => _finished = true);
      _persistScore();
      if (perfect) HapticFeedback.mediumImpact();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
    });
  }

  void _retry() {
    HapticFeedback.selectionClick();
    setState(() {
      _index = 0;
      _selected = null;
      _score = 0;
      _finished = false;
    });
  }

  Future<void> _persistScore() async {
    await WeeklyQuiz.saveScore(_score);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().quizScore.value = _score;
    }
  }

  Future<void> _shareScore() async {
    HapticFeedback.selectionClick();
    await SharePlus.instance.share(
      ShareParams(
        text: WeeklyQuiz.shareText(_score, _total),
        subject: '${WeeklyQuiz.weekLabel} Quiz',
      ),
    );
  }

  void _askBotanist() {
    HapticFeedback.selectionClick();
    final prompt =
        'I missed this on the ${WeeklyQuiz.weekLabel} quiz: "${_question.prompt}" '
        'The right answer is "${_question.options[_question.correctIndex]}". '
        '${_question.why} Can you explain it for houseplants?';
    openBotanistChat(
      plantName: '${WeeklyQuiz.weekLabel} Quiz',
      imagePath: AppImages.weeklyQuiz,
      isAssetImage: true,
    );
    if (Get.isRegistered<ChatbotController>()) {
      Get.find<ChatbotController>().send(preset: prompt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sageBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: NavigationHelper.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: AppColors.primaryGreen,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.medium.w,
            0,
            AppSpacing.medium.w,
            AppSpacing.medium.h,
          ),
          child: _finished ? _result() : _questionBody(),
        ),
      ),
    );
  }

  Widget _questionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CustomText(
              WeeklyQuiz.weekLabel,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
            const Spacer(),
            CustomText(
              '${_index + 1} of $_total',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ],
        ),
        SizedBox(height: AppSpacing.small.h),
        _ProgressBar(index: _index, total: _total),
        SizedBox(height: AppSpacing.medium.h),
        Expanded(
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: AppDurations.pageTransition,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (current, previous) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ...previous,
                    if (current != null) current,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.14, 0),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: SingleChildScrollView(
                key: ValueKey(_index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomText(
                      _question.prompt,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      height: 1.25,
                    ),
                    SizedBox(height: AppSpacing.medium.h),
                    for (var i = 0; i < _question.options.length; i++) ...[
                      if (i > 0) SizedBox(height: AppSpacing.small.h),
                      _OptionTile(
                        letter: _letters[i],
                        label: _question.options[i],
                        state: _optionState(i),
                        onTap: () => _pick(i),
                      ),
                    ],
                    AnimatedSize(
                      duration: AppDurations.normal,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _selected == null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: EdgeInsets.only(
                                top: AppSpacing.medium.h,
                              ),
                              child: CustomContainer(
                                color: AppColors.white,
                                borderRadius: AppRadius.large,
                                padding: EdgeInsets.all(AppSpacing.medium.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.spa_rounded,
                                          size: 18.sp,
                                          color: AppColors.primaryGreen,
                                        ),
                                        SizedBox(width: AppSpacing.small.w),
                                        Expanded(
                                          child: CustomText(
                                            _question.why,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.secondaryText,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_selected !=
                                        _question.correctIndex) ...[
                                      SizedBox(height: AppSpacing.small.h),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: 18.sp + AppSpacing.small.w,
                                        ),
                                        child: GestureDetector(
                                          onTap: _askBotanist,
                                          behavior: HitTestBehavior.opaque,
                                          child: const CustomText(
                                            'Ask Botanist',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.medium.h),
        CustomButton(
          text: _isLast ? 'See results' : 'Next',
          onPressed: _selected == null ? null : _next,
          enabled: _selected != null,
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
          disabledBackgroundColor:
              AppColors.primaryGreen.withValues(alpha: 0.16),
          disabledTextColor: AppColors.primaryGreen.withValues(alpha: 0.55),
          borderRadius: AppRadius.medium,
        ),
      ],
    );
  }

  _OptionState _optionState(int i) {
    if (_selected == null) return _OptionState.idle;
    if (i == _question.correctIndex) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  Widget _result() {
    final perfect = _score == _total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomText(
          WeeklyQuiz.weekLabel,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.secondaryText,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.medium.h),
        Expanded(
          child: CustomContainer(
            color: AppColors.white,
            borderRadius: AppRadius.extraLarge,
            shadow: AppShadows.diffused,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                const Positioned.fill(child: _ResultArt()),
                if (perfect)
                  const Positioned.fill(child: QuizPetalBurst()),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ColoredBox(
                    color: AppColors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.large.w,
                        vertical: AppSpacing.large.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (perfect) ...[
                            const CustomText(
                              'Congratulations',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(height: AppSpacing.extraSmall.h),
                          ],
                          CustomText(
                            WeeklyQuiz.resultTitle(_score, _total),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppSpacing.large.h),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: _score.toDouble()),
                            duration: AppDurations.slow,
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return _ScoreRing(
                                progress: _total == 0 ? 0 : value / _total,
                                label: '${value.round()}',
                                total: '$_total',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.medium.h),
        CustomButton(
          text: 'Retry',
          onPressed: _retry,
          backgroundColor: AppColors.white,
          textColor: AppColors.primaryGreen,
          borderRadius: AppRadius.medium,
        ),
        SizedBox(height: AppSpacing.small.h),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Done',
                onPressed: () => NavigationHelper.until(RouteNames.home),
                backgroundColor: AppColors.primaryGreen,
                textColor: AppColors.white,
                borderRadius: AppRadius.medium,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            CustomContainer(
              onTap: _shareScore,
              pressScale: 0.98,
              width: 54,
              height: 54,
              color: AppColors.white,
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.primaryGreen),
              alignment: Alignment.center,
              child: Icon(
                Icons.ios_share_rounded,
                color: AppColors.primaryGreen,
                size: 20.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResultArt extends StatelessWidget {
  const _ResultArt();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.extraLarge.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.weeklyQuiz,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.sageBackground,
                  AppColors.sageBackground.withValues(alpha: 0),
                ],
                stops: const [0, 0.35],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.progress,
    required this.label,
    required this.total,
  });

  final double progress;
  final String label;
  final String total;

  @override
  Widget build(BuildContext context) {
    final size = 120.r;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScoreRingPainter(
          progress: progress.clamp(0, 1),
          color: AppColors.primaryGreen,
          track: AppColors.sageBackground,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                label,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              CustomText(
                '/ $total',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  final double progress;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 8.0;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) SizedBox(width: AppSpacing.extraSmall.w),
          Expanded(
            child: AnimatedContainer(
              duration: AppDurations.normal,
              curve: Curves.easeOutCubic,
              height: 4.h,
              decoration: BoxDecoration(
                color: i <= index
                    ? AppColors.primaryGreen
                    : AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.circular.r),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String label;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color? border, Color accent, List<BoxShadow>? shadow) =
        switch (state) {
      _OptionState.correct => (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
          AppColors.success,
          null,
        ),
      _OptionState.wrong => (
          AppColors.error.withValues(alpha: 0.10),
          AppColors.error,
          AppColors.error,
          null,
        ),
      _OptionState.dimmed => (
          AppColors.white,
          null,
          AppColors.mutedText,
          null,
        ),
      _OptionState.idle => (
          AppColors.white,
          null,
          AppColors.primaryGreen,
          AppShadows.soft,
        ),
    };

    return Opacity(
      opacity: state == _OptionState.dimmed ? 0.55 : 1,
      child: CustomContainer(
        onTap: onTap,
        pressScale: 0.98,
        color: bg,
        borderRadius: AppRadius.medium,
        border: border == null ? null : Border.all(color: border),
        shadow: shadow,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.medium.w,
          vertical: AppSpacing.medium.h,
        ),
        child: Row(
          children: [
            CustomContainer(
              width: 28,
              height: 28,
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppRadius.circular,
              alignment: Alignment.center,
              child: state == _OptionState.correct
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.45, end: 1),
                      duration: AppDurations.normal,
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Icon(
                        Icons.check_rounded,
                        size: 16.sp,
                        color: accent,
                      ),
                    )
                  : CustomText(
                      letter,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: CustomText(
                label,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryText,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
