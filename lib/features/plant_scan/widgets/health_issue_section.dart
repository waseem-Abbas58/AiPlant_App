import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/plant_disease_hint_x.dart';
import '../model/plant_identify_result.dart';
import 'live_health_block.dart';

class HealthIssueSection extends StatefulWidget {
  const HealthIssueSection({
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
  State<HealthIssueSection> createState() => _HealthIssueSectionState();
}

class _HealthIssueSectionState extends State<HealthIssueSection> {
  var _pick = 0;

  @override
  void didUpdateWidget(covariant HealthIssueSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hint != widget.hint) _pick = 0;
  }

  List<PlantDiseaseHint> get _choices {
    final hint = widget.hint;
    if (hint == null || !hint.isSuccess || hint.healthy) return const [];
    return [hint.copyWith(alternatives: const []), ...hint.alternatives];
  }

  PlantDiseaseHint? get _shown {
    final choices = _choices;
    if (choices.isEmpty) return widget.hint;
    final index = _pick.clamp(0, choices.length - 1);
    return choices[index];
  }

  @override
  Widget build(BuildContext context) {
    final shown = _shown;
    final choices = _choices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          'Issue',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
        SizedBox(height: AppSpacing.small.h),
        LiveHealthBlock(
          loading: widget.loading,
          hint: shown,
          onCloserPhotos: widget.onCloserPhotos,
          onRetry: widget.onRetry,
        ),
        if (choices.length > 1) ...[
          SizedBox(height: AppSpacing.medium.h),
          const CustomText(
            'Also possible',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          SizedBox(height: 4.h),
          const CustomText(
            'Other live matches from this photo. Tap to see that solution.',
            fontSize: 12,
            color: AppColors.mutedText,
          ),
          SizedBox(height: AppSpacing.small.h),
          for (var i = 0; i < choices.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.small.h),
            _AltIssueRow(
              hint: choices[i],
              selected: i == _pick,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _pick = i);
              },
            ),
          ],
        ],
        if (shown != null &&
            shown.isSuccess &&
            (shown.hasSteps || shown.hasPrevention || shown.hasCaution)) ...[
          SizedBox(height: AppSpacing.large.h),
          const CustomText(
            'Solution',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          SizedBox(height: AppSpacing.small.h),
          HealthSolutionCard(hint: shown),
        ],
      ],
    );
  }
}

class _AltIssueRow extends StatelessWidget {
  const _AltIssueRow({
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final PlantDiseaseHint hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = hint.diseaseName.trim().isEmpty ? hint.title : hint.diseaseName;
    final meta = [
      if (hint.kind.trim().isNotEmpty) hint.kind.trim(),
      if (hint.confidencePercent > 0) '${hint.confidencePercent}%',
    ].join(' · ');
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.soft,
      border: selected
          ? Border.all(color: AppColors.primaryGreen, width: 1.4)
          : null,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  name,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (meta.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  CustomText(
                    meta,
                    fontSize: 12,
                    color: selected ? AppColors.primaryGreen : AppColors.mutedText,
                  ),
                ],
              ],
            ),
          ),
          Icon(
            selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
            size: 20.sp,
            color: selected ? AppColors.primaryGreen : AppColors.mutedText,
          ),
        ],
      ),
    );
  }
}
