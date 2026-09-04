import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../core/helpers/plant_image_store.dart';
import '../data/identify_flow.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/model/my_garden_model.dart';
import '../../my_garden/widgets/garden_sheet.dart';
import '../data/plant_identify_repository.dart';
import '../model/plant_identify_result.dart';
import '../../chatbot/data/botanist_navigator.dart';
import '../widgets/identify_result_hero.dart';
import '../widgets/identify_result_tabs.dart';
import '../widgets/health_issue_section.dart';
import '../widgets/live_health_block.dart';
import '../widgets/scan_live_faq.dart';
import '../widgets/toxicity_sheet.dart';

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
  late PlantIdentifyResult _identified;
  late final TextEditingController _nameController;
  late final FocusNode _nameFocus;
  final _scroll = ScrollController();
  var _saving = false;
  var _savingWishlist = false;
  var _editingName = false;
  var _selectedSimilar = -1;
  var _resultTab = IdentifyResultTabs.health;
  var _confirmed = false;
  var _highlightSimilar = false;
  final _similarKey = GlobalKey();
  PlantDiseaseHint? _health;
  var _healthLoading = false;
  var _healthRequest = 0;
  var _healthPick = 0;

  @override
  void initState() {
    super.initState();
    _identified = widget.result;
    _result = widget.result;
    _nameController = TextEditingController(text: _result.commonName);
    _nameFocus = FocusNode();
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus && _editingName) {
        setState(() => _editingName = false);
      }
    });
    if (widget.openToxicity && _result.toxicity != null) {
      _resultTab = IdentifyResultTabs.more;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openToxicity(_result.toxicity!);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadLiveHealth();
    });
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _nameController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _selectMatch(int index, PlantIdentifyMatch match) {
    // Tap again → back to top identify result.
    if (_selectedSimilar == index) {
      setState(() {
        _selectedSimilar = -1;
        _result = _identified;
        _nameController.text = _identified.commonName;
      });
      _loadLiveHealth();
      return;
    }
    setState(() {
      _selectedSimilar = index;
      _confirmed = true;
      _result = _identified.copyWith(
        commonName: match.commonName,
        scientificName: match.scientificName.isEmpty
            ? _identified.scientificName
            : match.scientificName,
        confidence: match.confidence > 0
            ? match.confidence
            : _identified.confidence,
        sampleImageAsset: match.imageAsset ?? _identified.sampleImageAsset,
        sampleImageUrl: match.imageUrl ?? _identified.sampleImageUrl,
        referenceImageUrls: (match.imageUrl ?? '').trim().startsWith('http')
            ? [match.imageUrl!.trim()]
            : _identified.referencePhotos,
      );
      _nameController.text = match.commonName;
    });
    _loadLiveHealth();
  }

  /// Live Water / Light / Soil only. Never invent fertilizer, air, or a meter.
  List<_CareGlanceItem> _careGlance(PlantIdentifyResult result) {
    if (result.isLocalPreview) return const [];
    final tips = result.careHighlights
        .map((tip) => tip.trim())
        .where((tip) => tip.isNotEmpty)
        .toList();
    final waterTip = _careTip(tips, const [
      'water',
      'moist',
      'humid',
      'soak',
      'drench',
      'dry',
    ]);
    final lightTip = _careTip(tips, const [
      'light',
      'sun',
      'shade',
      'bright',
      'direct',
    ]);
    final soilTip = _careTip(
      tips,
      const ['soil', 'drain', 'potting', 'mix'],
      skip: const ['dry'],
    );

    final care = result.care;
    final live = care != null && !result.isLocalPreview;
    final items = <_CareGlanceItem>[];

    final honestWater = _honestCare(waterTip);
    final days = live ? care!.waterDays : 0;
    if (honestWater != null || days > 0) {
      items.add(
        _CareGlanceItem(
          icon: Icons.water_drop_outlined,
          label: 'Water',
          value: honestWater ?? 'Every $days days',
          subtitle: honestWater != null && days > 0
              ? 'Typical: every $days days'
              : honestWater == null && days > 0
                  ? 'Typical schedule from this scan'
                  : '',
        ),
      );
    }

    final level = live ? care!.lightLevel.trim() : '';
    final honestLight = _honestCare(lightTip);
    if (honestLight != null || level == 'Bright' || level == 'Low') {
      items.add(
        _CareGlanceItem(
          icon: Icons.wb_sunny_outlined,
          label: 'Light',
          value: honestLight ?? '$level light',
          subtitle: honestLight != null && level.isNotEmpty
              ? '$level light'
              : '',
        ),
      );
    }

    final honestSoil = _honestCare(soilTip);
    if (honestSoil != null) {
      items.add(
        _CareGlanceItem(
          icon: Icons.grass_outlined,
          label: 'Soil',
          value: honestSoil,
        ),
      );
    }

    return items.where((item) => item.value.trim().isNotEmpty).toList();
  }

  String? _honestCare(String? tip) {
    final text = tip?.trim() ?? '';
    if (text.isEmpty) return null;
    final lower = text.toLowerCase();
    const filler = [
      'crucial',
      'essential for its',
      'important for its health',
      'properly is',
      'for its health and productivity',
    ];
    if (filler.any(lower.contains)) return null;
    if (text.length < 36 &&
        (lower.contains('properly') || lower.contains('regularly'))) {
      return null;
    }
    return text;
  }

  String? _careTip(
    List<String> tips,
    List<String> keys, {
    List<String> skip = const [],
  }) {
    for (final tip in tips) {
      final lower = tip.toLowerCase();
      if (skip.any(lower.contains)) continue;
      if (keys.any(lower.contains)) return tip;
    }
    return null;
  }

  void _selectResultTab(int index) {
    HapticFeedback.selectionClick();
    setState(() => _resultTab = index);
  }

  Future<void> _addCloserLeaf() async {
    if (!_canShowLiveHealth) return;
    final source = await showGardenSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large.w,
            AppSpacing.small.h,
            AppSpacing.large.w,
            AppSpacing.large.h + MediaQuery.paddingOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomContainer(
                width: 36,
                height: 4,
                color: AppColors.divider,
                borderRadius: AppRadius.circular,
              ),
              SizedBox(height: AppSpacing.medium.h),
              const CustomText(
                'Closer leaf photo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              SizedBox(height: 4.h),
              const CustomText(
                'One damaged leaf, fill the frame, daylight.',
                fontSize: 13,
                color: AppColors.secondaryText,
              ),
              SizedBox(height: AppSpacing.medium.h),
              _CloserSourceRow(
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.camera),
              ),
              _CloserSourceRow(
                icon: Icons.photo_outlined,
                label: 'Gallery',
                onTap: () =>
                    Navigator.of(sheetContext).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
    if (source == null || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (picked == null || !mounted) return;
    final stored = await PlantImageStore.persistCopy(picked.path);
    if (!mounted) return;
    setState(() {
      _result = _result.copyWith(imagePath: stored);
      _resultTab = IdentifyResultTabs.health;
    });
    await _diagnosePhoto(stored);
  }

  Future<void> _diagnosePhoto(String imagePath) async {
    final repository = _identifyRepository;
    if (repository == null) return;
    final request = ++_healthRequest;
    setState(() {
      _healthLoading = true;
      _health = null;
      _resultTab = IdentifyResultTabs.health;
    });
    final name = _nameController.text.trim().isEmpty
        ? _result.commonName
        : _nameController.text.trim();
    final hint = await IdentifyFlow.diagnoseSafe(
      repository: repository,
      imagePaths: [imagePath],
      plantName: name,
    );
    if (!mounted || request != _healthRequest) return;
    setState(() {
      _health = hint;
      _healthLoading = false;
      if (hint.isSuccess && !hint.healthy) {
        _resultTab = IdentifyResultTabs.health;
      } else if (hint.isSuccess && hint.healthy) {
        _resultTab = IdentifyResultTabs.care;
      }
    });
  }

  bool get _isResolvedIdentity {
    if (_result.shouldHideSpeciesName) return false;
    return switch (_result.confidenceTier) {
      IdentifyConfidenceTier.high => true,
      IdentifyConfidenceTier.medium => _confirmed || _selectedSimilar >= 0,
      IdentifyConfidenceTier.low => false,
    };
  }

  bool get _canDiagnose => _isResolvedIdentity;

  bool get _canShowLiveHealth =>
      !_result.shouldHideSpeciesName && !_result.isLocalPreview;

  String get _healthIssueLabel {
    final hint = _health;
    if (hint == null || !hint.isSuccess || hint.healthy) return '';
    final name = hint.diseaseName.trim();
    if (name.isNotEmpty) return name;
    return hint.title.trim();
  }

  PlantIdentifyRepository? get _identifyRepository {
    if (Get.isRegistered<PlantIdentifyRepository>()) {
      return Get.find<PlantIdentifyRepository>();
    }
    return null;
  }

  Future<void> _loadLiveHealth() async {
    if (!_canShowLiveHealth) {
      if (mounted) {
        setState(() {
          _health = null;
          _healthLoading = false;
        });
      }
      return;
    }
    final repository = _identifyRepository;
    if (repository == null) {
      if (mounted) {
        setState(() {
          _health = null;
          _healthLoading = false;
        });
      }
      return;
    }
    final request = ++_healthRequest;
    setState(() {
      _healthLoading = true;
      _health = null;
      _healthPick = 0;
    });
    final name = _nameController.text.trim().isEmpty
        ? _result.commonName
        : _nameController.text.trim();
    final hint = await IdentifyFlow.diagnoseSafe(
      repository: repository,
      imagePaths: [_result.imagePath],
      plantName: name,
    );
    if (!mounted || request != _healthRequest) return;
    setState(() {
      _health = hint;
      _healthLoading = false;
      if (hint.isSuccess && !hint.healthy) {
        _resultTab = IdentifyResultTabs.health;
      } else if (hint.isSuccess && hint.healthy) {
        _resultTab = IdentifyResultTabs.care;
      }
    });
  }

  bool get _canSave {
    final name = _nameController.text.trim();
    if (name.isEmpty || _result.shouldHideSpeciesName) return false;
    return _isResolvedIdentity;
  }

  void _confirmPlant() {
    HapticFeedback.lightImpact();
    setState(() => _confirmed = true);
  }

  void _notRightPlant() {
    setState(() {
      _highlightSimilar = true;
      _resultTab = IdentifyResultTabs.more;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _similarKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    });
  }

  void _retakePhoto() {
    Navigator.of(context).pop<String>();
  }

  Future<void> _pickReplacement({
    required ImageSource source,
    bool addAngle = false,
  }) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1600,
    );
    if (picked == null) return;
    final stored = await PlantImageStore.persistCopy(picked.path);
    if (!mounted) return;
    final paths = addAngle ? [_result.imagePath, stored] : [stored];
    final next = await IdentifyFlow.run(imagePaths: paths);
    if (next == null || !mounted) return;
    setState(() {
      _identified = next;
      _result = next;
      _nameController.text = next.commonName;
      _selectedSimilar = -1;
      _confirmed = next.confidenceTier == IdentifyConfidenceTier.high;
      _highlightSimilar = false;
      _editingName = false;
    });
    _loadLiveHealth();
  }

  Widget _tabBody(PlantIdentifyResult result) {
    return switch (_resultTab) {
      IdentifyResultTabs.care => _careTab(result),
      IdentifyResultTabs.more => _moreTab(result),
      _ => _healthTab(result),
    };
  }

  Widget _careTab(PlantIdentifyResult result) {
    final careItems = _careGlance(result);
    if (careItems.isEmpty) {
      return CustomContainer(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        shadow: AppShadows.soft,
        padding: EdgeInsets.all(AppSpacing.medium.w),
        child: const CustomText(
          'Water and light tips show here when the scan sends them.',
          fontSize: 14,
          color: AppColors.secondaryText,
          height: 1.35,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Care'),
        SizedBox(height: AppSpacing.small.h),
        for (var i = 0; i < careItems.length; i++) ...[
          if (i > 0) SizedBox(height: AppSpacing.small.h),
          _CareTile(item: careItems[i]),
        ],
        SizedBox(height: AppSpacing.small.h),
        const CustomText(
          'Save to garden to open Water Meter for this plant.',
          fontSize: 12,
          color: AppColors.mutedText,
        ),
      ],
    );
  }

  Widget _healthTab(PlantIdentifyResult result) {
    if (!_canShowLiveHealth) {
      return CustomContainer(
        color: AppColors.white,
        borderRadius: AppRadius.large,
        shadow: AppShadows.soft,
        padding: EdgeInsets.all(AppSpacing.medium.w),
        child: CustomText(
          result.isLocalPreview
              ? 'Issue and solution show after a live scan.'
              : 'Health details show when this plant is identified.',
          fontSize: 14,
          color: AppColors.secondaryText,
          height: 1.35,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HealthIssueSection(
          loading: _healthLoading,
          hint: _health,
          onCloserPhotos: _addCloserLeaf,
          onRetry: _loadLiveHealth,
        ),
        if (scanLiveFaqs(result: result, health: _health).isNotEmpty) ...[
          SizedBox(height: AppSpacing.large.h),
          ScanLiveFaq(items: scanLiveFaqs(result: result, health: _health)),
        ],
        SizedBox(height: AppSpacing.large.h),
        _ActionRow(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Ask Botanist',
          subtitle: 'More help about this issue',
          onTap: () => openBotanistChat(
            plantName: _nameController.text.trim().isEmpty
                ? result.commonName
                : _nameController.text.trim(),
            imagePath: result.imagePath,
            issue: _healthIssueLabel.isEmpty ? null : _healthIssueLabel,
          ),
        ),
      ],
    );
  }

  Widget _moreTab(PlantIdentifyResult result) {
    final similars = result.isLocalPreview
        ? const <PlantIdentifyMatch>[]
        : result.meaningfulSimilarMatches;
    final showPhotoRetry = !result.isLocalPreview &&
        _highlightSimilar &&
        result.confidenceTier == IdentifyConfidenceTier.medium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(key: _similarKey, height: 0),
        if (similars.isNotEmpty) ...[
          _SectionTitle(
            _highlightSimilar ? 'Pick the right match' : 'Similar matches',
          ),
          SizedBox(height: 4.h),
          const CustomText(
            'Tap a match if the top name looks wrong. Tap again to undo.',
            fontSize: 12,
            color: AppColors.mutedText,
          ),
          SizedBox(height: AppSpacing.small.h),
          SizedBox(
            height: 156.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              clipBehavior: Clip.none,
              itemCount: similars.length,
              separatorBuilder: (_, __) =>
                  SizedBox(width: AppSpacing.small.w),
              itemBuilder: (context, index) {
                final match = similars[index];
                return _SimilarCard(
                  match: match,
                  selected: _selectedSimilar == index,
                  emphasized: _highlightSimilar,
                  onTap: () => _selectMatch(index, match),
                );
              },
            ),
          ),
          SizedBox(height: AppSpacing.large.h),
        ] else if (showPhotoRetry) ...[
          const CustomText(
            'No other close matches found.',
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: AppSpacing.small.h),
          _RecoveryActions(
            onRetake: _retakePhoto,
            onGallery: () => _pickReplacement(source: ImageSource.gallery),
            onAngle: () => _pickReplacement(
              source: ImageSource.camera,
              addAngle: true,
            ),
          ),
          SizedBox(height: AppSpacing.large.h),
        ],
        if (showPhotoRetry && similars.isNotEmpty) ...[
          _RecoveryActions(
            onRetake: _retakePhoto,
            onGallery: () => _pickReplacement(source: ImageSource.gallery),
            onAngle: () => _pickReplacement(
              source: ImageSource.camera,
              addAngle: true,
            ),
          ),
          SizedBox(height: AppSpacing.large.h),
        ],
        if (!result.isLocalPreview && result.toxicity != null) ...[
          const _SectionTitle('Toxicity'),
          SizedBox(height: AppSpacing.small.h),
          _ToxicityCard(
            toxicity: result.toxicity!,
            onTap: () => _openToxicity(result.toxicity!),
          ),
          SizedBox(height: AppSpacing.large.h),
        ],
        if (scanLiveFaqs(result: result, health: _health).isNotEmpty) ...[
          ScanLiveFaq(items: scanLiveFaqs(result: result, health: _health)),
          SizedBox(height: AppSpacing.large.h),
        ],
        _ActionRow(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Ask Botanist',
          subtitle: 'Care questions about this plant',
          onTap: () => openBotanistChat(
            plantName: _nameController.text.trim().isEmpty
                ? result.commonName
                : _nameController.text.trim(),
            imagePath: result.imagePath,
            issue: _healthIssueLabel.isEmpty ? null : _healthIssueLabel,
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
    if (_result.shouldHideSpeciesName) return;
    setState(() => _editingName = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _nameFocus.requestFocus();
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (!_canSave || name.isEmpty || _saving || _savingWishlist) return;
    if (!Get.isRegistered<MyGardenController>()) return;
    setState(() => _saving = true);
    try {
      final garden = Get.find<MyGardenController>();
      final plant = await garden.addPickedPlantFromScan(
        path: _result.imagePath,
        name: name,
        scientificName: _result.scientificName,
        groupId: widget.groupId,
        care: _result.care,
      );
      if (!mounted) return;
      garden.completeGardenSave(plant.id, groupId: widget.groupId);
      if (!mounted) return;
      Navigator.of(context).pop<String>(plant.id);
      garden.openWaterMeter(plantId: plant.id);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveWishlist() async {
    final name = _nameController.text.trim();
    if (!_canSave || name.isEmpty || _saving || _savingWishlist) return;
    if (!Get.isRegistered<MyGardenController>()) return;
    setState(() => _savingWishlist = true);
    try {
      final garden = Get.find<MyGardenController>();
      await garden.addToWishlist(
        imagePath: _result.imagePath,
        name: name,
        scientificName: _result.scientificName,
        notify: false,
      );
      if (!mounted) return;
      garden.completeWishlistSave(name);
      if (!mounted) return;
      Navigator.of(context).pop<String>();
    } finally {
      if (mounted) setState(() => _savingWishlist = false);
    }
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
                    child: IdentifyResultHero(
                      path: result.imagePath,
                      referenceUrls: result.shouldHideSpeciesName
                          ? const []
                          : result.referencePhotos,
                      fallbackAsset: result.isLocalPreview
                          ? result.sampleImageAsset
                          : null,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.medium.w,
                        AppSpacing.medium.h,
                        AppSpacing.medium.w,
                        result.shouldHideSpeciesName
                            ? AppSpacing.large.h + bottomInset
                            : AppSpacing.large.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (result.shouldHideSpeciesName) ...[
                            const CustomText(
                              "We're not sure yet",
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                              letterSpacing: -0.4,
                            ),
                            SizedBox(height: 6.h),
                            const CustomText(
                              "We couldn't identify this plant confidently. Try another clear photo or a different angle.",
                              fontSize: 13,
                              color: AppColors.secondaryText,
                              height: 1.35,
                            ),
                            SizedBox(height: AppSpacing.medium.h),
                            _RecoveryActions(
                              onRetake: _retakePhoto,
                              onGallery: () => _pickReplacement(
                                source: ImageSource.gallery,
                              ),
                              onAngle: () => _pickReplacement(
                                source: ImageSource.camera,
                                addAngle: true,
                              ),
                            ),
                          ] else if (_editingName)
                            CustomTextField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              hintText: 'Plant name',
                              textCapitalization: TextCapitalization.sentences,
                              textInputAction: TextInputAction.done,
                              fillColor: AppColors.white,
                              focusedBorderColor: AppColors.primaryGreen,
                              enabledBorderColor: AppColors.border,
                              cursorColor: AppColors.primaryGreen,
                              borderRadius: 10,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                                letterSpacing: -0.4,
                                height: 1.2,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 14.h,
                              ),
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                          if (!result.shouldHideSpeciesName &&
                              result.scientificName.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            CustomText(
                              result.scientificName,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (!result.shouldHideSpeciesName) ...[
                            SizedBox(height: AppSpacing.small.h),
                            Row(
                              children: [
                                Flexible(
                                  child: _KindChip(
                                    label: result.kindLabel,
                                    kind: result.kind,
                                  ),
                                ),
                                if (result.isLocalPreview) ...[
                                  SizedBox(width: 8.w),
                                  const CustomText(
                                    'Preview',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.mutedText,
                                  ),
                                ] else ...[
                                  SizedBox(width: 8.w),
                                  const CustomText(
                                    'Identified',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ],
                                if (result.confidence > 0) ...[
                                  const Spacer(),
                                  _ConfidenceTierBadge(
                                    tier: result.confidenceTier,
                                  ),
                                ],
                              ],
                            ),
                            if (_healthIssueLabel.isNotEmpty) ...[
                              SizedBox(height: 8.h),
                              _IssueChip(
                                label: _healthIssueLabel,
                                onTap: () => _selectResultTab(
                                  IdentifyResultTabs.health,
                                ),
                              ),
                            ],
                            if (_showKindHint) ...[
                              SizedBox(height: 6.h),
                              CustomText(
                                result.kindHint,
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ],
                            if (result.confidence > 0) ...[
                              SizedBox(height: AppSpacing.small.h),
                              _ConfidenceBar(
                                value: result.confidence,
                                tier: result.confidenceTier,
                              ),
                              SizedBox(height: 6.h),
                              CustomText(
                                switch (result.confidenceTier) {
                                  IdentifyConfidenceTier.high =>
                                    'Looks like a strong match.',
                                  IdentifyConfidenceTier.medium =>
                                    result.meaningfulSimilarMatches.isEmpty
                                        ? 'Possible match — confirm this plant or try another photo.'
                                        : 'Possible match — confirm this plant or pick a close alternative.',
                                  IdentifyConfidenceTier.low =>
                                    'Try another clear photo or a different angle.',
                                },
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ],
                            if (result.confidenceTier ==
                                    IdentifyConfidenceTier.medium &&
                                !_confirmed &&
                                _selectedSimilar < 0) ...[
                              SizedBox(height: AppSpacing.medium.h),
                              const CustomText(
                                'Is this your plant?',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                              SizedBox(height: AppSpacing.small.h),
                              CustomButton(
                                text: 'Yes, this is my plant',
                                backgroundColor: AppColors.primaryGreen,
                                textColor: AppColors.white,
                                borderRadius: AppRadius.large,
                                onPressed: _confirmPlant,
                              ),
                              SizedBox(height: AppSpacing.small.h),
                              CustomContainer(
                                onTap: _notRightPlant,
                                color: AppColors.white,
                                borderRadius: AppRadius.large,
                                border: Border.all(color: AppColors.border),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                child: const CustomText(
                                  'Not the right plant',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.secondaryText,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!result.shouldHideSpeciesName)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: IdentifyResultPinHeader(
                        selected: _resultTab,
                        onSelect: _selectResultTab,
                      ),
                    ),
                  if (!result.shouldHideSpeciesName)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.medium.w,
                          AppSpacing.small.h,
                          AppSpacing.medium.w,
                          AppSpacing.large.h,
                        ),
                        child: _tabBody(result),
                      ),
                    ),
                ],
              ),
            ),
            if (!result.shouldHideSpeciesName)
              CustomContainer(
              color: AppColors.white,
              shadow: AppShadows.diffused,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                12.h,
                AppSpacing.medium.w,
                10.h + bottomInset,
              ),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Save to garden',
                    backgroundColor: AppColors.primaryGreen,
                    textColor: AppColors.white,
                    borderRadius: AppRadius.large,
                    enabled: !_saving && !_savingWishlist && _canSave,
                    isLoading: _saving,
                    onPressed: _save,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: CustomContainer(
                          onTap: (!_saving && !_savingWishlist && _canSave)
                              ? _saveWishlist
                              : null,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: CustomText(
                            'Save to wishlist',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: (!_saving && !_savingWishlist && _canSave)
                                ? AppColors.primaryGreen
                                : AppColors.mutedText,
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomContainer(
                          onTap: () => Navigator.of(context).pop<String>(),
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
    this.sampleUrl,
    this.sampleName = '',
  });

  final String path;
  final String? sampleAsset;
  final String? sampleUrl;
  final String sampleName;

  static const _heroH = 228.0;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final url = sampleUrl?.trim() ?? '';
    final hasUrl = url.startsWith('http');
    final hasAsset = sampleAsset != null && sampleAsset!.isNotEmpty;
    final hasSample = hasUrl || hasAsset;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        top + 8.h,
        AppSpacing.medium.w,
        0,
      ),
      child: SizedBox(
        height: _heroH.h,
        child: Stack(
          children: [
          SizedBox(
            height: _heroH.h,
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
                      child: hasUrl
                          ? Image.network(
                              url,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => const ColoredBox(
                                color: AppColors.divider,
                              ),
                            )
                          : Image.asset(
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
            Positioned(
              top: 10.h,
              left: 10.w,
              child: CustomContainer(
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
            ),
          ],
        ),
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
            shadow: AppShadows.diffused,
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
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryText,
      letterSpacing: -0.2,
    );
  }
}

class _IssueChip extends StatelessWidget {
  const _IssueChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.warning.withValues(alpha: 0.12),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.coronavirus_outlined,
            size: 14.sp,
            color: AppColors.warning,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: CustomText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.warning,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right_rounded,
            size: 16.sp,
            color: AppColors.warning,
          ),
        ],
      ),
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

class _ConfidenceTierBadge extends StatelessWidget {
  const _ConfidenceTierBadge({required this.tier});

  final IdentifyConfidenceTier tier;

  @override
  Widget build(BuildContext context) {
    final color = switch (tier) {
      IdentifyConfidenceTier.high => AppColors.primaryGreen,
      IdentifyConfidenceTier.medium => AppColors.warning,
      IdentifyConfidenceTier.low => AppColors.error,
    };
    return CustomContainer(
      color: color.withValues(alpha: 0.12),
      borderRadius: AppRadius.circular,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: CustomText(
        tier.label,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.value, required this.tier});

  final double value;
  final IdentifyConfidenceTier tier;

  @override
  Widget build(BuildContext context) {
    final color = switch (tier) {
      IdentifyConfidenceTier.high => AppColors.primaryGreen,
      IdentifyConfidenceTier.medium => AppColors.warning,
      IdentifyConfidenceTier.low => AppColors.error,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.circular.r),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: 8.h,
        backgroundColor: AppColors.border,
        color: color,
      ),
    );
  }
}

class _CareGlanceItem {
  const _CareGlanceItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle = '',
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
}

class _CareTile extends StatelessWidget {
  const _CareTile({required this.item, this.onTap});

  final _CareGlanceItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      color: AppColors.white,
      borderRadius: AppRadius.extraLarge,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          CustomContainer(
            width: 44,
            height: 44,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(
              item.icon,
              color: AppColors.primaryGreen,
              size: 22.sp,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  item.label,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  item.value,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.subtitle.trim().isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  CustomText(
                    item.subtitle,
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
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
    this.emphasized = false,
    required this.onTap,
  });

  final PlantIdentifyMatch match;
  final bool selected;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percent = (match.confidence.clamp(0, 1) * 100).round();
    final asset = match.imageAsset;
    final url = match.imageUrl;
    final borderColor = selected
        ? AppColors.primaryGreen
        : emphasized
            ? AppColors.warning
            : AppColors.border;
    final borderWidth = selected || emphasized ? 2.0 : 1.0;
    return CustomContainer(
      onTap: onTap,
      width: 118,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      border: Border.all(color: borderColor, width: borderWidth),
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: asset != null && asset.isNotEmpty
                ? Image.asset(asset, fit: BoxFit.cover)
                : url != null && url.isNotEmpty
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const _SimilarPlaceholder(),
                      )
                    : const _SimilarPlaceholder(),
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

class _SimilarPlaceholder extends StatelessWidget {
  const _SimilarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sageBackground,
      child: Center(
        child: Icon(
          Icons.local_florist_outlined,
          color: AppColors.primaryGreen.withValues(alpha: 0.55),
          size: 28.sp,
        ),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          const CustomText(
            'Learn more',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
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

class _HealthCheckCard extends StatelessWidget {
  const _HealthCheckCard({required this.onCheck});

  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onCheck,
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            width: 44,
            height: 44,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.medium,
            alignment: Alignment.center,
            child: Icon(
              Icons.health_and_safety_outlined,
              color: AppColors.primaryGreen,
              size: 22.sp,
            ),
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: CustomText(
                        'Health not checked',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    CustomContainer(
                      color: AppColors.sageBackground,
                      borderRadius: AppRadius.circular,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 5.h,
                      ),
                      child: CustomText(
                        'Check health',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                const CustomText(
                  'Run a separate health scan for spots, yellowing, pests or other problems.',
                  fontSize: 13,
                  color: AppColors.secondaryText,
                  height: 1.35,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryActions extends StatelessWidget {
  const _RecoveryActions({
    required this.onRetake,
    required this.onGallery,
    required this.onAngle,
  });

  final VoidCallback onRetake;
  final VoidCallback onGallery;
  final VoidCallback onAngle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Retake photo',
          backgroundColor: AppColors.primaryGreen,
          textColor: AppColors.white,
          borderRadius: AppRadius.large,
          onPressed: onRetake,
        ),
        SizedBox(height: AppSpacing.small.h),
        CustomContainer(
          onTap: onGallery,
          color: AppColors.white,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.primaryGreen),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: const CustomText(
            'Choose from Gallery',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryGreen,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: AppSpacing.small.h),
        CustomContainer(
          onTap: onAngle,
          color: AppColors.white,
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.border),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          child: const CustomText(
            'Add another angle',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText,
            textAlign: TextAlign.center,
          ),
        ),
      ],
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

class _LiveHealthBlock extends LiveHealthBlock {
  const _LiveHealthBlock({
    required super.loading,
    required super.hint,
    required super.onCloserPhotos,
    super.onRetry,
  });
}

class _CloserSourceRow extends StatelessWidget {
  const _CloserSourceRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: AppColors.primaryGreen),
          SizedBox(width: AppSpacing.medium.w),
          CustomText(
            label,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }
}

class _HealthStepRow extends HealthStepRow {
  const _HealthStepRow({
    required super.index,
    required super.text,
  });
}

