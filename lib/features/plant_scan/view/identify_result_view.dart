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
import '../../../shared/widgets/custom_text_field.dart';
import '../../my_garden/data/plant_care_engine.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/model/my_garden_model.dart';
import '../model/plant_identify_result.dart';
import '../widgets/toxicity_sheet.dart';
import '../../chatbot/data/botanist_navigator.dart';
import 'identify_disease_view.dart';

class IdentifyResultView extends StatefulWidget {
  const IdentifyResultView({
    super.key,
    required this.result,
    this.groupId = GardenGroup.generalId,
    this.openToxicity = false,
  });

  final PlantIdentifyResult result;
  final String groupId;
  final bool openToxicity;

  @override
  State<IdentifyResultView> createState() => _IdentifyResultViewState();
}

class _IdentifyResultViewState extends State<IdentifyResultView> {
  late PlantIdentifyResult _result;
  late final TextEditingController _nameController;
  var _saving = false;
  var _savingWishlist = false;
  var _selectedSimilar = -1;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
    _nameController = TextEditingController(text: _result.commonName);
    if (widget.openToxicity && _result.toxicity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openToxicity(_result.toxicity!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectMatch(int index, PlantIdentifyMatch match) {
    setState(() {
      _selectedSimilar = index;
      final care = _result.wantsWatering
          ? PlantCareEngine.sampleCareFor(match.commonName)
          : _result.care;
      _result = _result.copyWith(
        commonName: match.commonName,
        scientificName: match.scientificName,
        confidence: match.confidence,
        care: care,
        sampleImageAsset: match.imageAsset ?? _result.sampleImageAsset,
      );
      _nameController.text = match.commonName;
    });
  }

  List<String> _glanceChips(PlantIdentifyResult result) {
    final extras = result.careHighlights
        .where((item) => !item.startsWith('Every '))
        .toList();
    final care = result.care;
    if (care == null) return result.careHighlights;
    return [PlantCareEngine.waterHighlight(care), ...extras];
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving || _savingWishlist) return;
    if (!Get.isRegistered<MyGardenController>()) return;
    setState(() => _saving = true);
    final plant = Get.find<MyGardenController>().addPickedPlant(
      _result.imagePath,
      name: name,
      scientificName: _result.scientificName,
      groupId: widget.groupId,
      care: _result.care,
    );
    if (!mounted) return;
    NavigationHelper.back(_result.wantsWatering ? plant.id : null);
  }

  Future<void> _saveWishlist() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving || _savingWishlist) return;
    if (!Get.isRegistered<MyGardenController>()) return;
    setState(() => _savingWishlist = true);
    Get.find<MyGardenController>().addToWishlist(
      imagePath: _result.imagePath,
      name: name,
      scientificName: _result.scientificName,
    );
    if (!mounted) return;
    NavigationHelper.back();
  }

  void _openToxicity(PlantToxicity toxicity) {
    ToxicitySheet.show(
      context,
      toxicity: toxicity,
      plantName: _result.commonName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

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
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeroPhoto(
                      path: result.imagePath,
                      sampleAsset: result.sampleImageAsset,
                      sampleName: result.commonName,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.medium.w,
                        AppSpacing.medium.h,
                        AppSpacing.medium.w,
                        AppSpacing.large.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (result.isLocalPreview) ...[
                            const _SampleChip(),
                            SizedBox(height: AppSpacing.medium.h),
                          ],
                          Row(
                            children: [
                              _KindChip(label: result.kindLabel, kind: result.kind),
                              if (!result.isLocalPreview) ...[
                                const Spacer(),
                                _ConfidenceLabel(percent: result.confidencePercent),
                              ],
                            ],
                          ),
                          SizedBox(height: 6.h),
                          CustomText(
                            result.kindHint,
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                          if (!result.isLocalPreview) ...[
                            SizedBox(height: AppSpacing.small.h),
                            _ConfidenceBar(value: result.confidence),
                          ],
                          SizedBox(height: AppSpacing.medium.h),
                          CustomTextField(
                            controller: _nameController,
                            hintText: 'Plant name',
                            textCapitalization: TextCapitalization.sentences,
                            fillColor: AppColors.white,
                            focusedBorderColor: AppColors.primaryGreen,
                            cursorColor: AppColors.primaryGreen,
                            borderRadius: AppRadius.large,
                            onChanged: (_) => setState(() {}),
                          ),
                          if (result.scientificName.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.small.h),
                            CustomText(
                              result.scientificName,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                            ),
                          ],
                          if (_glanceChips(result).isNotEmpty) ...[
                            SizedBox(height: AppSpacing.medium.h),
                            const _SectionTitle('Care at a glance'),
                            SizedBox(height: AppSpacing.small.h),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: [
                                for (final item in _glanceChips(result))
                                  _CareChip(key: ValueKey(item), label: item),
                              ],
                            ),
                          ],
                          if (result.similarMatches.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.large.h),
                            const _SectionTitle('Similar plants'),
                            SizedBox(height: AppSpacing.small.h),
                            SizedBox(
                              height: 148.h,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: result.similarMatches.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(width: AppSpacing.small.w),
                                itemBuilder: (context, index) {
                                  final match = result.similarMatches[index];
                                  return _SimilarCard(
                                    match: match,
                                    selected: _selectedSimilar == index,
                                    onTap: () => _selectMatch(index, match),
                                  );
                                },
                              ),
                            ),
                          ],
                          if (result.toxicity != null) ...[
                            SizedBox(height: AppSpacing.large.h),
                            const _SectionTitle('Toxicity'),
                            SizedBox(height: AppSpacing.small.h),
                            _ToxicityCard(
                              toxicity: result.toxicity!,
                              onTap: () => _openToxicity(result.toxicity!),
                            ),
                          ],
                          SizedBox(height: AppSpacing.large.h),
                          const _SectionTitle('Next'),
                          SizedBox(height: AppSpacing.small.h),
                          _ActionRow(
                            icon: Icons.healing_outlined,
                            title: 'Diagnose disease',
                            subtitle: result.diseaseHint?.title ??
                                'Check this photo for leaf issues',
                            onTap: () => NavigationHelper.to(
                              () => IdentifyDiseaseView(
                                imagePath: result.imagePath,
                                plantName: _nameController.text.trim().isEmpty
                                    ? result.commonName
                                    : _nameController.text.trim(),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSpacing.small.h),
                          _ActionRow(
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'Ask Botanist',
                            subtitle: 'Care questions about this plant',
                            onTap: () => openBotanistChat(
                              plantName: _nameController.text.trim().isEmpty
                                  ? result.commonName
                                  : _nameController.text.trim(),
                              imagePath: result.imagePath,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomContainer(
              color: AppColors.white,
              shadow: AppShadows.soft,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                AppSpacing.small.h,
                AppSpacing.medium.w,
                AppSpacing.small.h + bottomInset,
              ),
              child: Column(
                children: [
                  CustomButton(
                    text: _result.wantsWatering
                        ? 'Save & set watering'
                        : 'Save to garden',
                    backgroundColor: AppColors.primaryGreen,
                    textColor: AppColors.white,
                    borderRadius: AppRadius.medium,
                    enabled: !_saving &&
                        !_savingWishlist &&
                        _nameController.text.trim().isNotEmpty,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                  SizedBox(height: AppSpacing.small.h),
                  CustomButton(
                    text: 'Save to wishlist',
                    backgroundColor: AppColors.sageBackground,
                    textColor: AppColors.primaryText,
                    borderRadius: AppRadius.medium,
                    enabled: !_saving &&
                        !_savingWishlist &&
                        _nameController.text.trim().isNotEmpty,
                    isLoading: _savingWishlist,
                    onPressed: _saveWishlist,
                  ),
                  CustomContainer(
                    onTap: NavigationHelper.back,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.small.h,
                    ),
                    child: const CustomText(
                      'Not now',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
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

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({
    required this.path,
    this.sampleAsset,
    this.sampleName = '',
  });

  final String path;
  final String? sampleAsset;
  final String sampleName;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final hasSample = sampleAsset != null && sampleAsset!.isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        top + 8.h,
        AppSpacing.medium.w,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            onTap: NavigationHelper.back,
            width: 36,
            height: 36,
            color: AppColors.white,
            borderRadius: AppRadius.circular,
            shadow: AppShadows.soft,
            alignment: Alignment.center,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16.sp,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: AppSpacing.small.h),
          SizedBox(
            height: 168.h,
            child: Row(
              children: [
                Expanded(
                  child: _PhotoTile(
                    label: 'Your photo',
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: AppColors.divider,
                      ),
                    ),
                  ),
                ),
                if (hasSample) ...[
                  SizedBox(width: AppSpacing.small.w),
                  Expanded(
                    child: _PhotoTile(
                      label: sampleName.isEmpty ? 'Sample' : sampleName,
                      child: Image.asset(
                        sampleAsset!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => const ColoredBox(
                          color: AppColors.divider,
                        ),
                      ),
                    ),
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

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CustomContainer(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            shadow: AppShadows.soft,
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.zero,
            child: child,
          ),
        ),
        SizedBox(height: 6.h),
        CustomText(
          label,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SampleChip extends StatelessWidget {
  const _SampleChip();

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.primaryGreen.withValues(alpha: 0.1),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: const CustomText(
        'Preview — live ID when AI is connected',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryText,
      letterSpacing: -0.28,
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({required this.label, required this.kind});

  final String label;
  final IdentifiedKind kind;

  @override
  Widget build(BuildContext context) {
    final isWeed = kind == IdentifiedKind.weed;
    final isDisease = kind == IdentifiedKind.disease;
    final color = isWeed || isDisease ? AppColors.warning : AppColors.primaryGreen;
    final icon = switch (kind) {
      IdentifiedKind.weed => Icons.grass_rounded,
      IdentifiedKind.tree => Icons.park_rounded,
      IdentifiedKind.mushroom => Icons.spa_outlined,
      IdentifiedKind.disease => Icons.coronavirus_outlined,
      _ => Icons.eco_rounded,
    };
    return CustomContainer(
      color: color.withValues(alpha: 0.12),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: color,
          ),
          SizedBox(width: 6.w),
          CustomText(
            label,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _ConfidenceLabel extends StatelessWidget {
  const _ConfidenceLabel({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      '$percent% match',
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryGreen,
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.circular.r),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 8.h,
        backgroundColor: AppColors.border,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class _CareChip extends StatelessWidget {
  const _CareChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.circular,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: CustomText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
      ),
    );
  }
}

class _SimilarCard extends StatelessWidget {
  const _SimilarCard({
    required this.match,
    required this.selected,
    required this.onTap,
  });

  final PlantIdentifyMatch match;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (match.confidence.clamp(0, 1) * 100).round();
    return CustomContainer(
      onTap: onTap,
      width: 112,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      border: selected
          ? Border.all(color: AppColors.primaryGreen, width: 2)
          : null,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: match.imageAsset == null
                ? const ColoredBox(color: AppColors.divider)
                : Image.asset(match.imageAsset!, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  match.commonName,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (match.confidence > 0)
                  CustomText(
                    '$percent%',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToxicityCard extends StatelessWidget {
  const _ToxicityCard({required this.toxicity, required this.onTap});

  final PlantToxicity toxicity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ToxicityFlag(
                icon: Icons.pets_rounded,
                label: toxicity.toxicToPets ? 'Toxic to pets' : 'Pets OK',
                alert: toxicity.toxicToPets,
              ),
              SizedBox(width: AppSpacing.small.w),
              _ToxicityFlag(
                icon: Icons.child_care_rounded,
                label: toxicity.toxicToKids ? 'Keep from kids' : 'Kids OK',
                alert: toxicity.toxicToKids,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            toxicity.summary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryText,
            height: 1.35,
          ),
        ],
      ),
    );
  }
}

class _ToxicityFlag extends StatelessWidget {
  const _ToxicityFlag({
    required this.icon,
    required this.label,
    required this.alert,
  });

  final IconData icon;
  final String label;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? AppColors.error : AppColors.success;
    return Expanded(
      child: CustomContainer(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.medium,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(width: 6.w),
            Expanded(
              child: CustomText(
                label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
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
            child: Icon(icon, color: AppColors.primaryGreen, size: 20.sp),
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
                  color: AppColors.primaryText,
                ),
                CustomText(
                  subtitle,
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}

