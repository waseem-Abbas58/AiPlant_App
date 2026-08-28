import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'garden_sheet.dart';

Future<void> showNewGroupSheet(
  BuildContext context, {
  String title = 'New Group',
  String confirmLabel = 'Create',
  String? initialName,
  bool canDelete = false,
  required ValueChanged<String> onSave,
  VoidCallback? onDelete,
}) {
  return showGardenSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _GroupSheet(
      title: title,
      confirmLabel: confirmLabel,
      initialName: initialName ?? '',
      canDelete: canDelete,
      onSave: onSave,
      onDelete: onDelete,
    ),
  );
}

class _GroupSheet extends StatefulWidget {
  const _GroupSheet({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.canDelete,
    required this.onSave,
    this.onDelete,
  });

  final String title;
  final String confirmLabel;
  final String initialName;
  final bool canDelete;
  final ValueChanged<String> onSave;
  final VoidCallback? onDelete;

  @override
  State<_GroupSheet> createState() => _GroupSheetState();
}

class _GroupSheetState extends State<_GroupSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop();
    widget.onSave(name);
  }

  void _delete() {
    Navigator.of(context).pop();
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.small.h,
        AppSpacing.large.w,
        AppSpacing.large.h +
            MediaQuery.paddingOf(context).bottom +
            bottomInset,
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
          CustomText(
            widget.title,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            letterSpacing: -0.28,
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomTextField(
            controller: _nameController,
            hintText: 'Group name',
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            fillColor: AppColors.sageBackground,
            focusedBorderColor: AppColors.primaryGreen,
            cursorColor: AppColors.primaryGreen,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
          if (widget.initialName.isEmpty) ...[
            SizedBox(height: AppSpacing.small.h),
            Wrap(
              spacing: AppSpacing.small.w,
              runSpacing: AppSpacing.small.h,
              children: const [
                'Living room',
                'Balcony',
                'Bedroom',
                'Kitchen',
              ].map((name) {
                return CustomContainer(
                  onTap: () {
                    _nameController.text = name;
                    setState(() {});
                  },
                  color: AppColors.sageBackground,
                  borderRadius: AppRadius.circular,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.medium.w,
                    vertical: 6.h,
                  ),
                  child: CustomText(
                    name,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                );
              }).toList(),
            ),
          ],
          if (widget.canDelete) ...[
            SizedBox(height: AppSpacing.small.h),
            CustomContainer(
              onTap: _delete,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
              child: const CustomText(
                'Delete Group',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
          SizedBox(height: AppSpacing.large.h),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  backgroundColor: AppColors.sageBackground,
                  textColor: AppColors.primaryText,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              SizedBox(width: AppSpacing.small.w),
              Expanded(
                child: CustomButton(
                  text: widget.confirmLabel,
                  backgroundColor: AppColors.primaryGreen,
                  textColor: AppColors.white,
                  enabled: _nameController.text.trim().isNotEmpty,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
