import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/plant_identify_result.dart';
import 'scan_photo_viewer.dart';

String _firstSentence(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return '';
  final match = RegExp(r'(.+?[.!?])(\s|$)').firstMatch(trimmed);
  final sentence = (match?.group(1) ?? trimmed).trim();
  if (sentence.length <= 140) return sentence;
  return '${sentence.substring(0, 137).trim()}…';
}

String _issueTitle(PlantDiseaseHint live) {
  if (live.healthy) {
    final title = live.title.trim();
    return title.isEmpty ? 'Looks healthy' : title;
  }
  final name = live.diseaseName.trim().isNotEmpty
      ? live.diseaseName.trim()
      : live.title.trim();
  return name.isEmpty ? 'Possible plant problem' : name;
}

String _issueSubtitle(PlantDiseaseHint live) {
  final parts = <String>[
    if (live.kind.trim().isNotEmpty) live.kind.trim(),
    if (live.severity.trim().isNotEmpty) live.severity.trim(),
  ];
  return parts.join(' · ');
}

class LiveHealthBlock extends StatelessWidget {
  const LiveHealthBlock({
    super.key,
    required this.loading,
    required this.hint,
    required this.onCloserPhotos,
    this.onRetry,
  });

  final bool loading;
  final PlantDiseaseHint? hint;
  final VoidCallback onCloserPhotos;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading || hint == null) {
      return CustomContainer(
        color: AppColors.white,
        borderRadius: AppRadius.extraLarge,
        shadow: AppShadows.soft,
        padding: EdgeInsets.all(AppSpacing.medium.w),
        child: Row(
          children: [
            SizedBox(
              width: 22.w,
              height: 22.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            const Expanded(
              child: CustomText(
                'Checking this photo for plant problems…',
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    final live = hint!;
    if (live.isSuccess && live.healthy) {
      return _IssueCard(
        title: _issueTitle(live),
        subtitle: _issueSubtitle(live),
        body: _firstSentence(live.summary).isEmpty
            ? 'This photo does not show a clear disease or pest problem.'
            : _firstSentence(live.summary),
        color: AppColors.success,
        icon: Icons.health_and_safety_outlined,
        imageUrl: live.imageUrl,
      );
    }

    if (live.isSuccess && !live.healthy) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IssueCard(
            title: _issueTitle(live),
            subtitle: _issueSubtitle(live),
            body: _firstSentence(live.summary),
            color: AppColors.warning,
            icon: Icons.coronavirus_outlined,
            imageUrl: live.imageUrl,
            symptoms:
                live.symptoms.take(3).where((s) => s.trim().isNotEmpty).toList(),
          ),
          if (live.diseaseName.trim().isEmpty) ...[
            SizedBox(height: AppSpacing.small.h),
            _HealthActionButton(
              label: 'Add a closer leaf photo',
              onTap: onCloserPhotos,
            ),
          ],
        ],
      );
    }

    final retryable = live.isRetryable && onRetry != null;
    final title = switch (live.failReason) {
      DiagnoseFailReason.offline => 'No internet',
      DiagnoseFailReason.timeout ||
      DiagnoseFailReason.serverError =>
        'Could not check health',
      _ => 'Issue not confirmed',
    };
    final body = retryable
        ? 'The health check did not finish. Try again, or add a closer leaf photo.'
        : 'This photo did not name a disease. Use one damaged leaf, fill the frame.';

    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          SizedBox(height: 4.h),
          CustomText(
            body,
            fontSize: 13,
            color: AppColors.secondaryText,
            height: 1.35,
          ),
          SizedBox(height: AppSpacing.small.h),
          if (retryable)
            _HealthActionButton(label: 'Try again', onTap: onRetry!)
          else
            _HealthActionButton(
              label: 'Add a closer leaf photo',
              onTap: onCloserPhotos,
            ),
        ],
      ),
    );
  }
}

class _HealthActionButton extends StatelessWidget {
  const _HealthActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.sageBackground,
      borderRadius: AppRadius.extraLarge,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: CustomText(
        label,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class HealthSolutionCard extends StatelessWidget {
  const HealthSolutionCard({super.key, required this.hint});

  final PlantDiseaseHint hint;

  @override
  Widget build(BuildContext context) {
    final steps = hint.steps
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .take(4)
        .toList();
    final prevention = _firstSentence(hint.prevention);
    final caution = hint.caution.trim();

    if (steps.isEmpty && prevention.isEmpty && caution.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            'What to do',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          if (prevention.isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              prevention,
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.35,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (steps.isNotEmpty) ...[
            SizedBox(height: AppSpacing.small.h),
            for (var i = 0; i < steps.length; i++) ...[
              if (i > 0) SizedBox(height: AppSpacing.small.h),
              HealthStepRow(index: i + 1, text: steps[i], compact: true),
            ],
          ],
          if (caution.isNotEmpty) ...[
            SizedBox(height: AppSpacing.small.h),
            CustomText(
              caution,
              fontSize: 12,
              color: AppColors.warning,
              height: 1.35,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class HealthStepRow extends StatelessWidget {
  const HealthStepRow({
    super.key,
    required this.index,
    required this.text,
    this.compact = false,
  });

  final int index;
  final String text;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final row = Row(
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
            height: 1.35,
          ),
        ),
      ],
    );

    if (compact) return row;

    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: row,
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.color,
    required this.icon,
    this.imageUrl,
    this.symptoms = const [],
  });

  final String title;
  final String subtitle;
  final String body;
  final Color color;
  final IconData icon;
  final String? imageUrl;
  final List<String> symptoms;

  @override
  Widget build(BuildContext context) {
    final photo = imageUrl?.trim() ?? '';
    final showPhoto = photo.startsWith('http');
    final showBody = body.trim().isNotEmpty &&
        body.trim().toLowerCase() != title.trim().toLowerCase();

    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showPhoto)
                CustomContainer(
                  onTap: () => openScanPhotoViewer(
                    context: context,
                    photos: [
                      ScanPhotoItem.url(photo, label: title),
                    ],
                  ),
                  width: 52,
                  height: 52,
                  color: AppColors.sageBackground,
                  borderRadius: AppRadius.medium,
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.zero,
                  child: Image.network(
                    photo,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      icon,
                      color: color,
                      size: 22.sp,
                    ),
                  ),
                )
              else
                CustomContainer(
                  width: 44,
                  height: 44,
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.medium,
                  alignment: Alignment.center,
                  child: Icon(icon, color: color, size: 20.sp),
                ),
              SizedBox(width: AppSpacing.small.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      CustomText(
                        subtitle,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (showBody) ...[
            SizedBox(height: AppSpacing.small.h),
            CustomText(
              body,
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.35,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (symptoms.isNotEmpty) ...[
            SizedBox(height: AppSpacing.small.h),
            for (final symptom in symptoms)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      '·  ',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    Expanded(
                      child: CustomText(
                        symptom,
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.35,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
