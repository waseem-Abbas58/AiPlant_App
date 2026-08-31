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
import '../../main_navigation/controller/main_navigation_controller.dart';
import '../../my_garden/data/plant_care_engine.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/model/my_garden_model.dart';
import '../model/plant_identify_result.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../../home/model/trending_plant.dart';
import '../widgets/identify_guide_panel.dart';
import '../widgets/toxicity_sheet.dart';
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
  late final FocusNode _nameFocus;
  final _scroll = ScrollController();
  final _overviewKey = GlobalKey();
  final _reqKey = GlobalKey();
  final _cultureKey = GlobalKey();
  final _faqKey = GlobalKey();
  final _articlesKey = GlobalKey();
  var _saving = false;
  var _savingWishlist = false;
  var _editingName = false;
  var _selectedSimilar = -1;
  var _guideTab = 0;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
    _nameController = TextEditingController(text: _result.commonName);
    _nameFocus = FocusNode();
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus && _editingName) {
        setState(() => _editingName = false);
      }
    });
    if (widget.openToxicity && _result.toxicity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openToxicity(_result.toxicity!);
      });
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _nameController.dispose();
    _scroll.dispose();
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

  List<_CareGlanceItem> _careGlance(PlantIdentifyResult result) {
    final care = result.care;
    if (care != null) {
      final days = PlantCareEngine.intervalDays(care);
      return [
        _CareGlanceItem(
          icon: Icons.water_drop_outlined,
          label: 'Water',
          value: 'Every $days days',
        ),
        _CareGlanceItem(
          icon: Icons.wb_sunny_outlined,
          label: 'Light',
          value: care.lightLevel,
        ),
        _CareGlanceItem(
          icon: Icons.south_outlined,
          label: 'Drain',
          value: 'Let extra drain',
        ),
      ];
    }
    const icons = [
      Icons.water_drop_outlined,
      Icons.wb_sunny_outlined,
      Icons.south_outlined,
    ];
    return [
      for (var i = 0; i < result.careHighlights.length && i < 3; i++)
        _CareGlanceItem(
          icon: icons[i],
          label: '',
          value: result.careHighlights[i],
        ),
    ];
  }

  TrendingPlant? get _guide {
    final typed = _nameController.text.trim();
    return TrendingPlant.byName(typed.isEmpty ? _result.commonName : typed) ??
        TrendingPlant.byName(_result.commonName);
  }

  Future<void> _jumpGuide(int index) async {
    HapticFeedback.selectionClick();
    setState(() => _guideTab = index);
    final key = switch (index) {
      0 => _overviewKey,
      1 => _reqKey,
      2 => _cultureKey,
      3 => _faqKey,
      _ => _articlesKey,
    };
    await Future<void>.delayed(const Duration(milliseconds: 16));
    final ctx = key.currentContext;
    if (ctx == null || !ctx.mounted) return;
    await Scrollable.ensureVisible(
      ctx,
      alignment: 0.12,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _openWater() {
    if (!Get.isRegistered<MyGardenController>()) return;
    Get.find<MyGardenController>().openWaterMeter();
  }

  Widget _scanExtras(PlantIdentifyResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_careGlance(result).isNotEmpty) ...[
          _CareGlance(items: _careGlance(result)),
        ],
        if (result.similarMatches.isNotEmpty) ...[
          SizedBox(height: AppSpacing.large.h),
          const _SectionTitle('Similar plants'),
          SizedBox(height: AppSpacing.small.h),
          SizedBox(
            height: 148.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
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
    );
  }

  bool get _showKindHint {
    return _result.kind == IdentifiedKind.weed ||
        _result.kind == IdentifiedKind.mushroom ||
        _result.kind == IdentifiedKind.disease;
  }

  void _startRename() {
    setState(() => _editingName = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving || _savingWishlist) return;
    if (!Get.isRegistered<MyGardenController>()) return;
    final plant = Get.find<MyGardenController>().addPickedPlant(
      _result.imagePath,
      name: name,
      scientificName: _result.scientificName,
      groupId: widget.groupId,
      care: _result.care,
      notify: false,
    );
    if (!context.mounted) return;
    if (Get.isRegistered<MainNavigationController>()) {
      Get.find<MainNavigationController>().onTabTapped(
        MainNavigationController.gardenIndex,
      );
    }
    Navigator.of(context).pop<String>(plant.id);
  }

  Future<void> _saveWishlist() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _saving || _savingWishlist) return;
    if (!Get.isRegistered<MyGardenController>()) return;
    Get.find<MyGardenController>().addToWishlist(
      imagePath: _result.imagePath,
      name: name,
      scientificName: _result.scientificName,
    );
    if (!context.mounted) return;
    Navigator.of(context).pop<String>();
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
                controller: _scroll,
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
                          if (_editingName)
                            CustomTextField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              hintText: 'Plant name',
                              height: 48,
                              isDense: true,
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              fillColor: AppColors.white,
                              focusedBorderColor: AppColors.primaryGreen,
                              cursorColor: AppColors.primaryGreen,
                              borderRadius: AppRadius.large,
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) =>
                                  setState(() => _editingName = false),
                            )
                          else
                            CustomContainer(
                              onTap: _startRename,
                              color: Colors.transparent,
                              padding: EdgeInsets.zero,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: CustomText(
                                      _nameController.text.trim().isEmpty
                                          ? 'Plant name'
                                          : _nameController.text.trim(),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: _nameController.text.trim().isEmpty
                                          ? AppColors.mutedText
                                          : AppColors.primaryText,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 4.h),
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: 18.sp,
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (result.scientificName.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            CustomText(
                              result.scientificName,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                            ),
                          ],
                          SizedBox(height: AppSpacing.small.h),
                          Row(
                            children: [
                              _KindChip(label: result.kindLabel, kind: result.kind),
                              if (result.isLocalPreview) ...[
                                SizedBox(width: 8.w),
                                const CustomText(
                                  'Preview',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.mutedText,
                                ),
                              ],
                              if (!result.isLocalPreview) ...[
                                const Spacer(),
                                _ConfidenceLabel(percent: result.confidencePercent),
                              ],
                            ],
                          ),
                          if (_showKindHint) ...[
                            SizedBox(height: 6.h),
                            CustomText(
                              result.kindHint,
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ],
                          if (!result.isLocalPreview) ...[
                            SizedBox(height: AppSpacing.small.h),
                            _ConfidenceBar(value: result.confidence),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_guide != null)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: IdentifyGuidePinHeader(
                        selected: _guideTab,
                        onSelect: _jumpGuide,
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
                      child: _guide == null
                          ? _scanExtras(result)
                          : IdentifyGuideSections(
                              plant: _guide!,
                              overviewKey: _overviewKey,
                              requirementsKey: _reqKey,
                              cultureKey: _cultureKey,
                              faqKey: _faqKey,
                              articlesKey: _articlesKey,
                              overviewLead: _scanExtras(result),
                              onWater: _openWater,
                              onChat: () => openBotanistChat(
                                plantName: _nameController.text.trim().isEmpty
                                    ? result.commonName
                                    : _nameController.text.trim(),
                                imagePath: result.imagePath,
                              ),
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
                    text: 'Save to garden',
                    backgroundColor: AppColors.primaryGreen,
                    textColor: AppColors.white,
                    borderRadius: AppRadius.large,
                    enabled: !_saving &&
                        !_savingWishlist &&
                        _nameController.text.trim().isNotEmpty,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomContainer(
                          onTap: (!_saving &&
                                  !_savingWishlist &&
                                  _nameController.text.trim().isNotEmpty)
                              ? _saveWishlist
                              : null,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: CustomText(
                            'Save to wishlist',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: (!_saving &&
                                    !_savingWishlist &&
                                    _nameController.text.trim().isNotEmpty)
                                ? AppColors.primaryGreen
                                : AppColors.mutedText,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomContainer(
                          onTap: NavigationHelper.back,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: const CustomText(
                            'Not now',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
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
            height: 200.h,
            child: Row(
              children: [
                Expanded(
                  child: _PhotoTile(
                    label: 'Your photo',
                    child: Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
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
                        alignment: Alignment.center,
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
            color: AppColors.sageBackground,
            borderRadius: AppRadius.extraLarge,
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
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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

class _CareGlanceItem {
  const _CareGlanceItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _CareGlance extends StatelessWidget {
  const _CareGlance({required this.items});

  final List<_CareGlanceItem> items;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium.w,
        vertical: AppSpacing.medium.h,
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              SizedBox(
                height: 40.h,
                child: const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
              ),
            Expanded(child: _CareGlanceCell(item: items[i])),
          ],
        ],
      ),
    );
  }
}

class _CareGlanceCell extends StatelessWidget {
  const _CareGlanceCell({required this.item});

  final _CareGlanceItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          item.icon,
          size: 22.sp,
          color: AppColors.primaryGreen,
        ),
        SizedBox(height: 6.h),
        if (item.label.isNotEmpty)
          CustomText(
            item.label,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedText,
          ),
        CustomText(
          item.value,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryText,
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
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
              children: [
                CustomText(
                  match.commonName,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (match.confidence > 0)
                  CustomText(
                    '$percent%',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                    textAlign: TextAlign.center,
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

