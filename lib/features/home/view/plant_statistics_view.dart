import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../my_garden/controller/my_garden_controller.dart';
import '../../my_garden/model/my_garden_model.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';

enum _StatsPeriod { month, threeMonths, sixMonths, total }

class PlantStatisticsView extends StatefulWidget {
  const PlantStatisticsView({super.key});

  @override
  State<PlantStatisticsView> createState() => _PlantStatisticsViewState();
}

class _PlantStatisticsViewState extends State<PlantStatisticsView> {
  var _period = _StatsPeriod.month;
  var _identifyOpen = true;
  var _careOpen = false;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? get _rangeStart {
    final end = _today;
    return switch (_period) {
      _StatsPeriod.month => DateTime(end.year, end.month, 1),
      _StatsPeriod.threeMonths => DateTime(end.year, end.month - 2, 1),
      _StatsPeriod.sixMonths => DateTime(end.year, end.month - 5, 1),
      _StatsPeriod.total => null,
    };
  }

  String get _rangeLabel {
    final end = _today;
    final start = _rangeStart;
    if (start == null) return 'All time';
    return '${DateFormat('MMMM dd').format(start)} - ${DateFormat('MMMM dd, y').format(end)}';
  }

  bool _inRange(DateTime date) {
    final start = _rangeStart;
    final day = DateTime(date.year, date.month, date.day);
    if (day.isAfter(_today)) return false;
    if (start == null) return true;
    return !day.isBefore(start);
  }

  _CareCounts _careCounts(Set<String> keys) {
    final counts = _CareCounts();
    final pattern = RegExp(
      r'-(water|mist|fertilizer|rotate|cut)-(\d+)-(\d+)-(\d+)$',
    );
    for (final key in keys) {
      final match = pattern.firstMatch(key);
      if (match == null) continue;
      final date = DateTime(
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
      );
      if (!_inRange(date)) continue;
      switch (match.group(1)) {
        case 'water':
          counts.water++;
          break;
        case 'mist':
          counts.mist++;
          break;
        case 'fertilizer':
          counts.fertilizer++;
          break;
        case 'rotate':
          counts.rotate++;
          break;
        case 'cut':
          counts.cut++;
          break;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final garden = Get.isRegistered<MyGardenController>()
        ? Get.find<MyGardenController>()
        : null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        body: SafeArea(
          child: Column(
            children: [
              const GardenSubpageHeader(title: 'Plant Statistics'),
              _PeriodTabs(
                period: _period,
                onChanged: (value) => setState(() => _period = value),
              ),
              Expanded(
                child: garden == null
                    ? const SizedBox.shrink()
                    : Obx(() {
                        final snaps = garden.snaps.toList();
                        final care = _careCounts(garden.completedKeys);
                        return ListView(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.medium.w,
                            AppSpacing.small.h,
                            AppSpacing.medium.w,
                            AppSpacing.large.h,
                          ),
                          children: [
                            CustomContainer(
                              color: const Color(0xFFE8F0E6),
                              borderRadius: AppRadius.large,
                              padding: EdgeInsets.all(AppSpacing.medium.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CustomText(
                                    'Your plant statistics',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryText,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    _rangeLabel,
                                    fontSize: 13,
                                    color: AppColors.secondaryText,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSpacing.large.h),
                            const _SectionTitle('Identification'),
                            SizedBox(height: AppSpacing.small.h),
                            _StatBlock(
                              icon: Icons.crop_free_rounded,
                              value: '${snaps.length}',
                              label: snaps.length == 1
                                  ? 'Plant identified'
                                  : 'Plants identified',
                              expanded: _identifyOpen,
                              onTap: () => setState(
                                () => _identifyOpen = !_identifyOpen,
                              ),
                              child: snaps.isEmpty
                                  ? const CustomText(
                                      'No identifications yet. Scan a plant to see it here.',
                                      fontSize: 13,
                                      color: AppColors.secondaryText,
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const CustomText(
                                          'Recent identifications',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondaryText,
                                        ),
                                        SizedBox(height: 8.h),
                                        for (final snap in snaps.take(8))
                                          _IdentifyRow(snap: snap),
                                      ],
                                    ),
                            ),
                            SizedBox(height: AppSpacing.large.h),
                            const _SectionTitle('Care'),
                            SizedBox(height: AppSpacing.small.h),
                            _StatBlock(
                              icon: Icons.check_rounded,
                              value: '${care.total}',
                              label: 'Total care done',
                              expanded: _careOpen,
                              onTap: () => setState(
                                () => _careOpen = !_careOpen,
                              ),
                              child: _CareBreakdown(counts: care),
                            ),
                            SizedBox(height: AppSpacing.large.h),
                            const _SectionTitle('Diagnosis'),
                            SizedBox(height: AppSpacing.small.h),
                            const _StatBlock(
                              icon: Icons.favorite_border_rounded,
                              value: '0',
                              label: 'Plants diagnosed',
                            ),
                          ],
                        );
                      }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareCounts {
  var water = 0;
  var mist = 0;
  var fertilizer = 0;
  var rotate = 0;
  var cut = 0;

  int get total => water + mist + fertilizer + rotate + cut;

  int percent(int value) {
    if (total == 0) return 0;
    return ((value / total) * 100).round();
  }
}

class _PeriodTabs extends StatelessWidget {
  const _PeriodTabs({required this.period, required this.onChanged});

  final _StatsPeriod period;
  final ValueChanged<_StatsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium.w),
      child: Row(
        children: [
          for (final entry in const [
            (_StatsPeriod.month, '1 month'),
            (_StatsPeriod.threeMonths, '3 months'),
            (_StatsPeriod.sixMonths, '6 months'),
            (_StatsPeriod.total, 'Total'),
          ])
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(entry.$1),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Column(
                    children: [
                      CustomText(
                        entry.$2,
                        fontSize: 13,
                        fontWeight: period == entry.$1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: period == entry.$1
                            ? AppColors.primaryText
                            : AppColors.mutedText,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2.h,
                        color: period == entry.$1
                            ? AppColors.primaryText
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.primaryText,
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.value,
    required this.label,
    this.expanded = false,
    this.onTap,
    this.child,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool expanded;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          CustomContainer(
            onTap: onTap,
            padding: EdgeInsets.all(AppSpacing.medium.w),
            child: Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18.sp, color: AppColors.white),
                ),
                SizedBox(width: AppSpacing.small.w + 4.w),
                CustomText(
                  value,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                SizedBox(width: AppSpacing.small.w),
                Expanded(
                  child: CustomText(
                    label,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                if (onTap != null)
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.chevron_right_rounded,
                    size: 22.sp,
                    color: AppColors.mutedText,
                  ),
              ],
            ),
          ),
          if (expanded && child != null)
            Container(
              width: double.infinity,
              color: AppColors.sageBackground,
              padding: EdgeInsets.all(AppSpacing.medium.w),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _IdentifyRow extends StatelessWidget {
  const _IdentifyRow({required this.snap});

  final GardenSnap snap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            snap.name,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          if (snap.scientificName.trim().isNotEmpty)
            CustomText(
              snap.scientificName,
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
        ],
      ),
    );
  }
}

class _CareBreakdown extends StatelessWidget {
  const _CareBreakdown({required this.counts});

  final _CareCounts counts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64.w,
          height: 64.w,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.local_florist_rounded,
            size: 28.sp,
            color: AppColors.primaryGreen,
          ),
        ),
        SizedBox(height: AppSpacing.medium.h),
        _CareRow(
          icon: Icons.science_outlined,
          color: const Color(0xFF8D6E63),
          label: 'Fertilizing',
          percent: counts.percent(counts.fertilizer),
        ),
        _CareRow(
          icon: Icons.content_cut_rounded,
          color: AppColors.primaryGreen,
          label: 'Cutting',
          percent: counts.percent(counts.cut),
        ),
        _CareRow(
          icon: Icons.water_drop_outlined,
          color: AppColors.blue,
          label: 'Watering',
          percent: counts.percent(counts.water),
        ),
        _CareRow(
          icon: Icons.sync_rounded,
          color: AppColors.warning,
          label: 'Rotating',
          percent: counts.percent(counts.rotate),
        ),
        _CareRow(
          icon: Icons.air_rounded,
          color: AppColors.secondaryGreen,
          label: 'Misting',
          percent: counts.percent(counts.mist),
          last: true,
        ),
      ],
    );
  }
}

class _CareRow extends StatelessWidget {
  const _CareRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.percent,
    this.last = false,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int percent;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: CustomText(
              label,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          CustomText(
            '$percent%',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }
}
