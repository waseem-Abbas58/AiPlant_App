import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../data/identify_flow.dart';
import '../data/plant_identify_repository.dart';
import '../model/plant_identify_result.dart';

import 'diagnose_symptom_view.dart';

class IdentifyDiseaseView extends StatefulWidget {
  const IdentifyDiseaseView({
    super.key,
    required this.imagePaths,
    this.plantName = '',
    this.symptomId = '',
  });

  final List<String> imagePaths;
  final String plantName;
  final String symptomId;

  String get imagePath => imagePaths.isEmpty ? '' : imagePaths.first;

  @override
  State<IdentifyDiseaseView> createState() => _IdentifyDiseaseViewState();
}

class _IdentifyDiseaseViewState extends State<IdentifyDiseaseView> {
  PlantDiseaseHint? _hint;
  var _loading = true;
  var _canRetry = false;

  PlantIdentifyRepository get _repository {
    if (Get.isRegistered<PlantIdentifyRepository>()) {
      return Get.find<PlantIdentifyRepository>();
    }
    return LocalPlantIdentifyRepository();
  }

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    setState(() {
      _loading = true;
      _canRetry = false;
    });
    final hint = await IdentifyFlow.diagnoseSafe(
      repository: _repository,
      imagePaths: widget.imagePaths,
      plantName: widget.plantName,
      symptomId: widget.symptomId,
    );
    if (!mounted) return;
    setState(() {
      _hint = hint;
      _loading = false;
      _canRetry = hint.isRetryable;
    });
  }

  ImageProvider _photo() {
    final path = widget.imagePath;
    if (path.isEmpty) {
      return const AssetImage('assets/images/plant_identifier.png');
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    return FileImage(File(path));
  }

  @override
  Widget build(BuildContext context) {
    final hint = _hint;
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: Column(
          children: [
            SizedBox(
              height: 220.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: _photo(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: AppColors.nearBlack,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Color(0x00000000),
                          Color(0x99000000),
                        ],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: top + 8.h,
                    left: AppSpacing.medium.w,
                    child: CustomContainer(
                      onTap: NavigationHelper.back,
                      width: 36,
                      height: 36,
                      color: AppColors.white.withValues(alpha: 0.94),
                      borderRadius: AppRadius.circular,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16.sp,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.medium.w,
                    right: AppSpacing.medium.w,
                    bottom: AppSpacing.medium.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          widget.plantName.trim().isEmpty
                              ? 'Health check'
                              : widget.plantName.trim(),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.symptomId.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          CustomText(
                            DiagnoseSymptom.labelFor(widget.symptomId),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white.withValues(alpha: 0.88),
                          ),
                        ],
                        if (widget.imagePaths.length > 1) ...[
                          SizedBox(height: 2.h),
                          CustomText(
                            '${widget.imagePaths.length} health photos',
                            fontSize: 11,
                            color: AppColors.white.withValues(alpha: 0.75),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading || hint == null
                  ? _DiagnoseLoading()
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.medium.w,
                        AppSpacing.large.h,
                        AppSpacing.medium.w,
                        AppSpacing.extraLarge.h,
                      ),
                      children: [
                        _StatusHero(hint: hint),
                        SizedBox(height: AppSpacing.large.h),
                        const _SectionLabel('Issue'),
                        SizedBox(height: AppSpacing.small.h),
                        _FindingCard(hint: hint),
                        if (hint.hasSymptoms) ...[
                          SizedBox(height: AppSpacing.medium.h),
                          _BulletCard(items: hint.symptoms),
                        ],
                        SizedBox(height: AppSpacing.large.h),
                        const _SectionLabel('Solution'),
                        SizedBox(height: AppSpacing.small.h),
                        if (hint.hasSteps)
                          ...[
                            for (var i = 0; i < hint.steps.length; i++) ...[
                              if (i > 0) SizedBox(height: AppSpacing.small.h),
                              _StepCard(index: i + 1, text: hint.steps[i]),
                            ],
                          ]
                        else
                          _StepsEmpty(healthy: hint.healthy),
                        if (hint.hasPrevention) ...[
                          SizedBox(height: AppSpacing.large.h),
                          const _SectionLabel('Prevention'),
                          SizedBox(height: AppSpacing.small.h),
                          _TextCard(text: hint.prevention),
                        ],
                        if (hint.hasCaution) ...[
                          SizedBox(height: AppSpacing.large.h),
                          const _SectionLabel('Caution'),
                          SizedBox(height: AppSpacing.small.h),
                          _TextCard(
                            text: hint.caution,
                            tone: _TextCardTone.caution,
                          ),
                        ],
                        if (hint.hosts.trim().isNotEmpty ||
                            hint.spreadsWhen.trim().isNotEmpty) ...[
                          SizedBox(height: AppSpacing.large.h),
                          const _SectionLabel('Also know'),
                          SizedBox(height: AppSpacing.small.h),
                          _AlsoKnowCard(hint: hint),
                        ],
                        if (_canRetry) ...[
                          SizedBox(height: AppSpacing.large.h),
                          CustomButton(
                            text: 'Try again',
                            backgroundColor: AppColors.primaryGreen,
                            textColor: AppColors.white,
                            borderRadius: AppRadius.large,
                            onPressed: _run,
                          ),
                        ],
                        SizedBox(height: AppSpacing.large.h),
                        const _SectionLabel('Ask'),
                        SizedBox(height: AppSpacing.small.h),
                        CustomContainer(
                          onTap: () => openBotanistChat(
                            plantName: widget.plantName,
                            imagePath: widget.imagePath,
                            issue: hint.diseaseName.trim().isNotEmpty
                                ? hint.diseaseName.trim()
                                : hint.title.trim(),
                          ),
                          color: AppColors.white,
                          borderRadius: AppRadius.large,
                          shadow: AppShadows.soft,
                          padding: EdgeInsets.all(AppSpacing.medium.w),
                          child: Row(
                            children: [
                              CustomContainer(
                                width: 40,
                                height: 40,
                                color: AppColors.sageBackground,
                                borderRadius: AppRadius.medium,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 20.sp,
                                ),
                              ),
                              SizedBox(width: AppSpacing.small.w),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      'Ask Botanist',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText,
                                    ),
                                    CustomText(
                                      'Ask about this issue or what to do next',
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.mutedText,
                                size: 22.sp,
                              ),
                            ],
                          ),
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

class _DiagnoseLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36.w,
            height: 36.w,
            child: const CircularProgressIndicator(
              color: AppColors.primaryGreen,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          const CustomText(
            'Analyzing health photos…',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.mutedText,
      letterSpacing: 0.2,
    );
  }
}

class _StatusHero extends StatelessWidget {
  const _StatusHero({required this.hint});

  final PlantDiseaseHint hint;

  @override
  Widget build(BuildContext context) {
    final issue = !hint.healthy;
    final color = issue ? AppColors.warning : AppColors.success;
    final icon = issue
        ? Icons.coronavirus_outlined
        : Icons.health_and_safety_outlined;
    final status = hint.isLocalPreview && hint.failReason != DiagnoseFailReason.none
        ? 'Preview'
        : (issue ? 'Possible issue' : 'Looks healthy');

    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          CustomContainer(
            width: 52,
            height: 52,
            color: color.withValues(alpha: 0.14),
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 26.sp),
          ),
          SizedBox(width: AppSpacing.medium.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomContainer(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.circular,
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  child: CustomText(
                    status,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomText(
                  hint.title,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  letterSpacing: -0.3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hint.diseaseName.trim().isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  CustomText(
                    hint.diseaseName,
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ],
                if (hint.kind.trim().isNotEmpty ||
                    hint.severity.trim().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      if (hint.kind.trim().isNotEmpty)
                        _MetaChip(label: hint.kind.trim()),
                      if (hint.severity.trim().isNotEmpty)
                        _MetaChip(label: hint.severity.trim()),
                    ],
                  ),
                ],
                if (hint.confidence > 0) ...[
                  SizedBox(height: 6.h),
                  CustomText(
                    '${hint.confidencePercent}% confidence',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FindingCard extends StatelessWidget {
  const _FindingCard({required this.hint});

  final PlantDiseaseHint hint;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: CustomText(
        hint.summary,
        fontSize: 15,
        color: AppColors.secondaryText,
        height: 1.45,
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            width: 28,
            height: 28,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.circular,
            alignment: Alignment.center,
            child: CustomText(
              '$index',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: CustomText(
              text,
              fontSize: 14,
              color: AppColors.primaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepsEmpty extends StatelessWidget {
  const _StepsEmpty({required this.healthy});

  final bool healthy;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            healthy
                ? Icons.check_circle_outline_rounded
                : Icons.list_alt_rounded,
            color: AppColors.primaryGreen,
            size: 22.sp,
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: CustomText(
              healthy
                  ? 'No treatment steps needed right now. Keep your usual care routine.'
                  : 'Clear fix steps will show here when diagnosis finds a specific issue.',
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.sageBackground,
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      child: CustomText(
        label,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.small.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
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
                    color: AppColors.primaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

enum _TextCardTone { normal, caution }

class _TextCard extends StatelessWidget {
  const _TextCard({
    required this.text,
    this.tone = _TextCardTone.normal,
  });

  final String text;
  final _TextCardTone tone;

  @override
  Widget build(BuildContext context) {
    final caution = tone == _TextCardTone.caution;
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            caution
                ? Icons.warning_amber_rounded
                : Icons.shield_outlined,
            color: caution ? AppColors.warning : AppColors.primaryGreen,
            size: 20.sp,
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: CustomText(
              text,
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlsoKnowCard extends StatelessWidget {
  const _AlsoKnowCard({required this.hint});

  final PlantDiseaseHint hint;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hint.hosts.trim().isNotEmpty) ...[
            const CustomText(
              'Often on',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
            SizedBox(height: 4.h),
            CustomText(
              hint.hosts,
              fontSize: 14,
              color: AppColors.primaryText,
              height: 1.35,
            ),
          ],
          if (hint.hosts.trim().isNotEmpty &&
              hint.spreadsWhen.trim().isNotEmpty)
            SizedBox(height: AppSpacing.small.h),
          if (hint.spreadsWhen.trim().isNotEmpty) ...[
            const CustomText(
              'Spreads when',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
            ),
            SizedBox(height: 4.h),
            CustomText(
              hint.spreadsWhen,
              fontSize: 14,
              color: AppColors.primaryText,
              height: 1.35,
            ),
          ],
        ],
      ),
    );
  }
}
