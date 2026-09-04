import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/plant_identify_result.dart';

class ScanFaqItem {
  const ScanFaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}

List<ScanFaqItem> scanLiveFaqs({
  required PlantIdentifyResult result,
  PlantDiseaseHint? health,
}) {
  if (result.isLocalPreview) return const [];
  final name = result.commonName.trim().isEmpty ? 'this plant' : result.commonName.trim();
  final items = <ScanFaqItem>[];

  final waterDays = result.care?.waterDays ?? 0;
  if (waterDays > 0) {
    items.add(
      ScanFaqItem(
        question: 'How often should I water $name?',
        answer:
            'Typical from this scan: every $waterDays days. Check soil before watering.',
      ),
    );
  } else {
    final tip = _firstTip(result.careHighlights, const ['water']);
    if (tip != null) {
      items.add(
        ScanFaqItem(
          question: 'How should I water $name?',
          answer: tip,
        ),
      );
    }
  }

  final light = _firstTip(result.careHighlights, const ['light', 'sun']);
  if (light != null && light.trim().isNotEmpty) {
    items.add(
      ScanFaqItem(
        question: 'How much light does $name need?',
        answer: light.trim(),
      ),
    );
  }

  final toxicity = result.toxicity;
  if (toxicity != null) {
    items.add(
      ScanFaqItem(
        question: 'Is $name safe for pets or kids?',
        answer: toxicity.summary.trim().isEmpty
            ? 'Open Toxicity on this screen for the live safety note.'
            : toxicity.summary.trim(),
      ),
    );
  }

  if (health != null &&
      health.isSuccess &&
      !health.healthy &&
      health.diseaseName.trim().isNotEmpty) {
    final issue = health.diseaseName.trim();
    final about = health.summary.trim();
    if (about.isNotEmpty) {
      items.add(
        ScanFaqItem(
          question: 'What is $issue?',
          answer: about,
        ),
      );
    }
    if (health.steps.isNotEmpty) {
      items.add(
        ScanFaqItem(
          question: 'How do I treat $issue?',
          answer: health.steps.take(3).join(' '),
        ),
      );
    }
  }

  return items.take(6).toList();
}

String? _firstTip(List<String> tips, List<String> keys) {
  for (final tip in tips) {
    final lower = tip.toLowerCase();
    if (keys.any(lower.contains)) {
      final trimmed = tip.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
  }
  return null;
}

class ScanLiveFaq extends StatelessWidget {
  const ScanLiveFaq({super.key, required this.items});

  final List<ScanFaqItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          'FAQ',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
        ),
        SizedBox(height: 4.h),
        const CustomText(
          'From this scan only — not a generic article.',
          fontSize: 12,
          color: AppColors.mutedText,
        ),
        SizedBox(height: AppSpacing.small.h),
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.small.h),
          _FaqTile(item: items[i]),
        ],
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.item});

  final ScanFaqItem item;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: 4.h,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.only(bottom: 10.h),
          iconColor: AppColors.primaryGreen,
          collapsedIconColor: AppColors.mutedText,
          title: CustomText(
            item.question,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                item.answer,
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
