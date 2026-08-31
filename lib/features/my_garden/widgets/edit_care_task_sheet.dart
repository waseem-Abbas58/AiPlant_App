import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../model/my_garden_model.dart';
import 'garden_sheet.dart';

enum GardenCareKind { water, mist, fertilizer, rotate, cut }

class CareTaskDraft {
  const CareTaskDraft({
    required this.repeatLabel,
    required this.time,
    required this.autoReminders,
    this.deleted = false,
  });

  final String repeatLabel;
  final String time;
  final bool autoReminders;
  final bool deleted;
}

Future<CareTaskDraft?> showEditCareTaskSheet(
  BuildContext context, {
  required GardenPlant plant,
  required GardenCareKind kind,
}) {
  return showGardenSheet<CareTaskDraft>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _EditCareTaskSheet(plant: plant, kind: kind),
  );
}

class _EditCareTaskSheet extends StatefulWidget {
  const _EditCareTaskSheet({required this.plant, required this.kind});

  final GardenPlant plant;
  final GardenCareKind kind;

  @override
  State<_EditCareTaskSheet> createState() => _EditCareTaskSheetState();
}

class _EditCareTaskSheetState extends State<_EditCareTaskSheet> {
  static const _repeats = [
    '3 Days',
    '7 Days',
    '14 Days',
    '1 Month',
    '2 Months',
    '6 Months',
  ];
  static const _times = [
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '6:00 PM',
    '8:00 PM',
  ];

  late String _repeat;
  late String _time;
  late bool _auto;

  @override
  void initState() {
    super.initState();
    final care = widget.plant.care;
    _time = care.waterTime;
    _auto = care.autoReminders;
    _repeat = switch (widget.kind) {
      GardenCareKind.water => '${care.waterDays} Days',
      GardenCareKind.mist => '${care.mistDays} Days',
      GardenCareKind.fertilizer => '${care.fertilizerMonths} Months',
      GardenCareKind.rotate => '${care.rotateMonths} Month',
      GardenCareKind.cut => '${care.cutMonths} Months',
    };
  }

  String get _kindLabel => switch (widget.kind) {
        GardenCareKind.water => 'Watering',
        GardenCareKind.mist => 'Misting',
        GardenCareKind.fertilizer => 'Fertilizer',
        GardenCareKind.rotate => 'Rotate',
        GardenCareKind.cut => 'Cut',
      };

  Future<void> _pick(List<String> options, String current, ValueChanged<String> onPick) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        var draft = current;
        return Container(
          height: 260.h,
          color: AppColors.white,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  onPressed: () {
                    onPick(draft);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 36,
                  scrollController: FixedExtentScrollController(
                    initialItem: options.contains(current)
                        ? options.indexOf(current)
                        : 0,
                  ),
                  onSelectedItemChanged: (index) => draft = options[index],
                  children: [
                    for (final option in options)
                      Center(child: Text(option)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.small.h,
        AppSpacing.large.w,
        AppSpacing.large.h + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CustomContainer(
              width: 36,
              height: 4,
              color: AppColors.divider,
              borderRadius: AppRadius.circular,
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          const CustomText(
            'Edit Task',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            letterSpacing: -0.28,
          ),
          SizedBox(height: 4.h),
          CustomText(
            '${widget.plant.name} · $_kindLabel',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomContainer(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium.w),
            child: Column(
              children: [
                _TaskRow(
                  icon: Icons.repeat_rounded,
                  title: 'Repeat',
                  value: _repeat,
                  onTap: () => _pick(_repeats, _repeat, (value) {
                    setState(() => _repeat = value);
                  }),
                ),
                Divider(color: AppColors.divider, height: 1.h),
                _TaskRow(
                  icon: Icons.schedule_outlined,
                  title: 'Time',
                  value: _time,
                  onTap: () => _pick(_times, _time, (value) {
                    setState(() => _time = value);
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomContainer(
            color: AppColors.white,
            borderRadius: AppRadius.large,
            padding: EdgeInsets.all(AppSpacing.medium.w),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Auto Reminders',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                      CustomText(
                        'Notify me about my care reminders',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondaryText,
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: _auto,
                  activeTrackColor: AppColors.primaryGreen,
                  onChanged: (value) => setState(() => _auto = value),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.large.h),
          CustomButton(
            text: 'Save',
            backgroundColor: AppColors.primaryGreen,
            textColor: AppColors.white,
            borderRadius: AppRadius.large,
            onPressed: () => Navigator.of(context).pop(
              CareTaskDraft(
                repeatLabel: _repeat,
                time: _time,
                autoReminders: _auto,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomButton(
            text: 'Delete Task',
            backgroundColor: AppColors.error,
            textColor: AppColors.white,
            borderRadius: AppRadius.large,
            onPressed: () => Navigator.of(context).pop(
              CareTaskDraft(
                repeatLabel: _repeat,
                time: _time,
                autoReminders: _auto,
                deleted: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: AppColors.secondaryText),
          SizedBox(width: AppSpacing.medium.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                CustomText(
                  value,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColors.mutedText,
            ),
        ],
      ),
    );
  }
}
