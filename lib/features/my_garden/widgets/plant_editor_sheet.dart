import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../core/helpers/plant_image_store.dart';
import 'garden_sheet.dart';

class PlantEditorDraft {
  const PlantEditorDraft({
    required this.name,
    required this.imagePath,
    this.deleted = false,
  });

  final String name;
  final String imagePath;
  final bool deleted;
}

Future<PlantEditorDraft?> showPlantEditorSheet(
  BuildContext context, {
  required String imagePath,
  required bool isAssetImage,
  required String initialName,
  required bool isNew,
  Future<String?> Function()? onPickPhoto,
  Future<String?> Function(String path)? onCrop,
}) {
  return showGardenSheet<PlantEditorDraft>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _PlantEditorSheet(
      imagePath: imagePath,
      isAssetImage: isAssetImage,
      initialName: initialName,
      isNew: isNew,
      onPickPhoto: onPickPhoto,
      onCrop: onCrop,
    ),
  );
}

class _PlantEditorSheet extends StatefulWidget {
  const _PlantEditorSheet({
    required this.imagePath,
    required this.isAssetImage,
    required this.initialName,
    required this.isNew,
    this.onPickPhoto,
    this.onCrop,
  });

  final String imagePath;
  final bool isAssetImage;
  final String initialName;
  final bool isNew;
  final Future<String?> Function()? onPickPhoto;
  final Future<String?> Function(String path)? onCrop;

  @override
  State<_PlantEditorSheet> createState() => _PlantEditorSheetState();
}

class _PlantEditorSheetState extends State<_PlantEditorSheet> {
  late final TextEditingController _nameController;
  late String _imagePath;
  late bool _isAssetImage;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _imagePath = widget.imagePath;
    _isAssetImage = widget.isAssetImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    if (_busy || widget.onPickPhoto == null) return;
    setState(() => _busy = true);
    final path = await widget.onPickPhoto!();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (path != null && path.isNotEmpty) {
        _imagePath = path;
        _isAssetImage = path.startsWith('assets/');
      }
    });
  }

  Future<void> _cropPhoto() async {
    if (_busy || _isAssetImage || widget.onCrop == null) return;
    setState(() => _busy = true);
    final path = await widget.onCrop!(_imagePath);
    if (!mounted) return;
    if (path != null && path.isNotEmpty) {
      await PlantImageStore.evict(_imagePath);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (path != null && path.isNotEmpty) {
        _imagePath = path;
        _isAssetImage = false;
      }
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _busy) return;
    Navigator.of(context).pop(
      PlantEditorDraft(name: name, imagePath: _imagePath),
    );
  }

  void _delete() {
    if (_busy) return;
    Navigator.of(context).pop(
      const PlantEditorDraft(name: '', imagePath: '', deleted: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canSave = _nameController.text.trim().isNotEmpty && !_busy;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.large.w,
        AppSpacing.small.h,
        AppSpacing.large.w,
        AppSpacing.large.h +
            MediaQuery.paddingOf(context).bottom +
            bottomInset,
      ),
      child: SingleChildScrollView(
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
            widget.isNew ? 'Add Plant' : 'Edit Plant',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            letterSpacing: -0.28,
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomContainer(
            height: 180,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.large,
            clipBehavior: Clip.antiAlias,
            onTap: _isAssetImage ? _changePhoto : _cropPhoto,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: _isAssetImage
                      ? Image.asset(
                          _imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        )
                      : Image(
                          image: FileImage(File(_imagePath)),
                          fit: BoxFit.cover,
                          key: ValueKey(_imagePath),
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                ),
                if (_busy)
                  const ColoredBox(
                    color: Color(0x66000000),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else
                  Positioned(
                    right: 10.w,
                    bottom: 10.h,
                    child: CustomContainer(
                      color: AppColors.white.withValues(alpha: 0.92),
                      borderRadius: AppRadius.circular,
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isAssetImage
                                ? Icons.photo_outlined
                                : Icons.crop_rounded,
                            size: 16.sp,
                            color: AppColors.primaryGreen,
                          ),
                          SizedBox(width: 4.w),
                          CustomText(
                            _isAssetImage ? 'Change' : 'Edit',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomContainer(
            onTap: _changePhoto,
            color: AppColors.sageBackground,
            borderRadius: AppRadius.circular,
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            child: const CustomText(
              'Change Photo',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomTextField(
            controller: _nameController,
            hintText: 'Plant name',
            autofocus: widget.isNew,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            fillColor: AppColors.sageBackground,
            focusedBorderColor: AppColors.primaryGreen,
            cursorColor: AppColors.primaryGreen,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          if (!widget.isNew) ...[
            SizedBox(height: AppSpacing.small.h),
            CustomContainer(
              onTap: _delete,
              padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
              child: const CustomText(
                'Delete Plant',
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
                  text: widget.isNew ? 'Add' : 'Save',
                  backgroundColor: AppColors.primaryGreen,
                  textColor: AppColors.white,
                  enabled: canSave,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
