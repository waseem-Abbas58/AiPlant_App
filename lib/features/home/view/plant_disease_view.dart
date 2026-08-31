import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../../plant_scan/controller/plant_scan_controller.dart';
import '../model/plant_disease.dart';

class _Tint {
  static const water = Color(0xFF1E88E5);
  static const warn = Color(0xFFFB8C00);
}

class PlantDiseaseView extends StatefulWidget {
  const PlantDiseaseView({
    super.key,
    required this.disease,
    this.heroTag,
  });

  final PlantDisease disease;
  final String? heroTag;

  static void open(PlantDisease disease, {required String heroTag}) {
    HapticFeedback.selectionClick();
    NavigationHelper.to(
      () => PlantDiseaseView(disease: disease, heroTag: heroTag),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  @override
  State<PlantDiseaseView> createState() => _PlantDiseaseViewState();
}

class _PlantDiseaseViewState extends State<PlantDiseaseView> {
  static const _jumps = ['Overview', 'Treat', 'Prevent'];

  final _sheet = DraggableScrollableController();
  final _overviewKey = GlobalKey();
  final _treatKey = GlobalKey();
  final _preventKey = GlobalKey();
  var _minSize = 0.4;
  var _closing = false;
  var _jump = 0;

  PlantDisease get disease => widget.disease;

  @override
  void initState() {
    super.initState();
    _sheet.addListener(_onSheet);
  }

  @override
  void dispose() {
    _sheet.removeListener(_onSheet);
    _sheet.dispose();
    super.dispose();
  }

  void _onSheet() {
    if (_closing || !_sheet.isAttached) return;
    if (_sheet.size > _minSize + 0.01) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NavigationHelper.back();
    });
  }

  Future<void> _jumpTo(int index) async {
    HapticFeedback.selectionClick();
    setState(() => _jump = index);
    final key = switch (index) {
      0 => _overviewKey,
      1 => _treatKey,
      _ => _preventKey,
    };
    if (_sheet.isAttached && _sheet.size < 0.97) {
      await _sheet.animateTo(
        1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    final ctx = key.currentContext;
    if (ctx == null || !ctx.mounted) return;
    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.06,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _share() async {
    HapticFeedback.selectionClick();
    final symptoms = [
      for (var i = 0; i < disease.symptoms.length; i++)
        '• ${disease.symptoms[i]}',
    ].join('\n');
    final steps = [
      for (var i = 0; i < disease.treatSteps.length; i++)
        '${i + 1}. ${disease.treatSteps[i]}',
    ].join('\n');
    final body = StringBuffer('${disease.title}\n\n${disease.overview}');
    if (disease.hosts != null) {
      body.write('\n\nOften on ${disease.hosts}');
    }
    if (symptoms.isNotEmpty) {
      body.write('\n\nSymptoms\n$symptoms');
    }
    if (steps.isNotEmpty) {
      body.write('\n\nHow to treat\n$steps');
    }
    if (disease.prevention != null) {
      body.write('\n\nPrevention\n${disease.prevention}');
    }
    await SharePlus.instance.share(
      ShareParams(text: body.toString(), subject: disease.title),
    );
  }

  void _scanLeaf() {
    HapticFeedback.selectionClick();
    if (Get.isRegistered<PlantScanController>()) {
      Get.find<PlantScanController>().selectCategory(3);
    }
    final navigator = Get.key.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
    if (!Get.isRegistered<MainNavigationController>()) return;
    Get.find<MainNavigationController>()
        .onTabTapped(MainNavigationController.scanIndex);
  }

  void _openLookalike() {
    final other = disease.lookalike;
    if (other == null) return;
    PlantDiseaseView.open(other, heroTag: other.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final overlap = 28.h;
    final headerHeight = 0.42.sh;
    final sheetRest = ((media.height - headerHeight + overlap) / media.height)
        .clamp(0.52, 0.64)
        .toDouble();
    _minSize = (sheetRest - 0.14).clamp(0.36, sheetRest - 0.05);
    final guide = disease.hasGuide;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Hero(
                tag: widget.heroTag ?? disease.imagePath,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      disease.imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: headerHeight,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.black.withValues(alpha: 0.22),
                          ],
                          stops: const [0.55, 1],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DraggableScrollableSheet(
              controller: _sheet,
              initialChildSize: sheetRest,
              minChildSize: _minSize,
              maxChildSize: 1,
              snap: true,
              snapSizes: [sheetRest, 1],
              builder: (context, scrollController) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.sageBackground,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.extraLarge.r),
                    ),
                    boxShadow: AppShadows.medium,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.large.w,
                            0,
                            AppSpacing.large.w,
                            AppSpacing.large.h,
                          ),
                          children: [
                            _sheetHandle(),
                            const CustomText(
                              'Plant Diseases',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                            SizedBox(height: AppSpacing.small.h),
                            CustomText(
                              disease.title,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                              height: 1.15,
                              letterSpacing: -0.4,
                            ),
                            if (disease.kind != null ||
                                disease.severity != null) ...[
                              SizedBox(height: AppSpacing.small.h),
                              Wrap(
                                spacing: AppSpacing.small.w,
                                runSpacing: AppSpacing.small.h,
                                children: [
                                  if (disease.kind != null)
                                    _MetaChip(
                                      label: disease.kind!,
                                      color: AppColors.primaryGreen,
                                    ),
                                  if (disease.severity != null)
                                    _MetaChip(
                                      label: disease.severity!,
                                      color: _Tint.warn,
                                    ),
                                ],
                              ),
                            ],
                            if (disease.hosts != null) ...[
                              SizedBox(height: AppSpacing.small.h),
                              CustomText(
                                'Often on ${disease.hosts}',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryText,
                                height: 1.35,
                              ),
                            ],
                            if (guide) ...[
                              SizedBox(height: AppSpacing.medium.h),
                              Wrap(
                                spacing: AppSpacing.small.w,
                                runSpacing: AppSpacing.small.h,
                                children: [
                                  for (var i = 0; i < _jumps.length; i++)
                                    _JumpChip(
                                      label: _jumps[i],
                                      selected: _jump == i,
                                      onTap: () => _jumpTo(i),
                                    ),
                                ],
                              ),
                            ],
                            if (disease.overview.isNotEmpty) ...[
                              SizedBox(height: AppSpacing.medium.h),
                              KeyedSubtree(
                                key: _overviewKey,
                                child: _SectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _Heading('Overview'),
                                      CustomText(
                                        disease.overview,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.secondaryText,
                                        height: 1.55,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (guide) ...[
                              _SectionCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Heading('Symptoms'),
                                    ..._bulletRows(disease.symptoms),
                                  ],
                                ),
                              ),
                              KeyedSubtree(
                                key: _treatKey,
                                child: _SectionCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const _Heading('How to treat'),
                                      ..._stepRows(disease.treatSteps),
                                    ],
                                  ),
                                ),
                              ),
                              KeyedSubtree(
                                key: _preventKey,
                                child: Column(
                                  children: [
                                    if (disease.spreadsWhen != null)
                                      _Callout(
                                        title: 'Spreads when',
                                        body: disease.spreadsWhen!,
                                        icon: Icons.water_drop_rounded,
                                        accent: _Tint.water,
                                      ),
                                    _Callout(
                                      title: 'Prevention',
                                      body: disease.prevention!,
                                      icon: Icons.shield_rounded,
                                      accent: AppColors.primaryGreen,
                                    ),
                                    if (disease.lookalike != null &&
                                        disease.lookalikeHint != null)
                                      _LookalikeRow(
                                        other: disease.lookalike!,
                                        hint: disease.lookalikeHint!,
                                        onTap: _openLookalike,
                                      ),
                                    _Callout(
                                      title: 'Caution',
                                      body: disease.caution!,
                                      icon: Icons.info_outline_rounded,
                                      accent: AppColors.error,
                                    ),
                                  ],
                                ),
                              ),
                              CustomContainer(
                                onTap: _scanLeaf,
                                pressScale: 0.98,
                                color: AppColors.white,
                                borderRadius: AppRadius.large,
                                shadow: AppShadows.soft,
                                padding: EdgeInsets.all(AppSpacing.medium.w),
                                child: Row(
                                  children: [
                                    CustomContainer(
                                      width: 36,
                                      height: 36,
                                      color: AppColors.primaryGreen.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: AppRadius.medium,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.document_scanner_outlined,
                                        size: 18.sp,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.small.w),
                                    const Expanded(
                                      child: CustomText(
                                        'Scan a leaf to check this on your plant',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14.sp,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (guide)
                        _StickyActions(
                          onAsk: () {
                            HapticFeedback.selectionClick();
                            openBotanistChat(
                              plantName: disease.title,
                              imagePath: disease.imagePath,
                              isAssetImage: true,
                            );
                          },
                          onShare: _share,
                        ),
                    ],
                  ),
                );
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium.w),
                  child: GestureDetector(
                    onTap: NavigationHelper.back,
                    behavior: HitTestBehavior.opaque,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      child: SizedBox(
                        width: 36.r,
                        height: 36.r,
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.secondaryText,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
      child: Center(
        child: Container(
          width: 36.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
        ),
      ),
    );
  }

  static List<Widget> _bulletRows(List<String> items) {
    return [
      for (var i = 0; i < items.length; i++) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 7.h),
              child: CustomContainer(
                width: 6,
                height: 6,
                color: AppColors.primaryGreen,
                borderRadius: AppRadius.circular,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: CustomText(
                items[i],
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
        if (i < items.length - 1) SizedBox(height: AppSpacing.small.h),
      ],
    ];
  }

  static List<Widget> _stepRows(List<String> steps) {
    return [
      for (var i = 0; i < steps.length; i++) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              width: 24,
              height: 24,
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: AppRadius.circular,
              alignment: Alignment.center,
              child: CustomText(
                '${i + 1}',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: CustomText(
                  steps[i],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        if (i < steps.length - 1) SizedBox(height: AppSpacing.medium.h),
      ],
    ];
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small.h),
      child: CustomText(
        title,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryText,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: color.withValues(alpha: 0.12),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.small.w,
        vertical: 5.h,
      ),
      child: CustomText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

class _JumpChip extends StatelessWidget {
  const _JumpChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      pressScale: 0.98,
      color: selected ? AppColors.primaryGreen : AppColors.white,
      borderRadius: AppRadius.medium,
      border: selected ? null : Border.all(color: AppColors.border),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: CustomText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: selected ? AppColors.white : AppColors.secondaryText,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.medium.h),
      child: CustomContainer(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        shadow: AppShadows.soft,
        padding: EdgeInsets.all(AppSpacing.medium.w),
        child: child,
      ),
    );
  }
}

class _Callout extends StatelessWidget {
  const _Callout({
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.medium.h),
      child: CustomContainer(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        shadow: AppShadows.soft,
        padding: EdgeInsets.all(AppSpacing.medium.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              width: 36,
              height: 36,
              color: accent.withValues(alpha: 0.12),
              borderRadius: AppRadius.medium,
              alignment: Alignment.center,
              child: Icon(icon, color: accent, size: 18.sp),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    title,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: title == 'Caution' ? accent : AppColors.primaryText,
                  ),
                  CustomText(
                    body,
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LookalikeRow extends StatelessWidget {
  const _LookalikeRow({
    required this.other,
    required this.hint,
    required this.onTap,
  });

  final PlantDisease other;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.medium.h),
      child: CustomContainer(
        onTap: onTap,
        pressScale: 0.98,
        color: AppColors.white,
        borderRadius: AppRadius.large,
        shadow: AppShadows.soft,
        padding: EdgeInsets.all(AppSpacing.medium.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium.r),
              child: Image.asset(
                other.imagePath,
                width: 48.r,
                height: 48.r,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Don’t confuse with',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                  CustomText(
                    other.title,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                  CustomText(
                    hint,
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    height: 1.35,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyActions extends StatelessWidget {
  const _StickyActions({required this.onAsk, required this.onShare});

  final VoidCallback onAsk;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.divider),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large.w,
            AppSpacing.small.h,
            AppSpacing.large.w,
            AppSpacing.small.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Ask Botanist',
                  backgroundColor: AppColors.primaryGreen,
                  borderRadius: AppRadius.medium,
                  height: 48,
                  onPressed: onAsk,
                ),
              ),
              SizedBox(width: AppSpacing.small.w),
              CustomContainer(
                onTap: onShare,
                pressScale: 0.98,
                width: 48,
                height: 48,
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
        ),
      ),
    );
  }
}
