import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/components/custom_snackbar.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart'; 
import '../../../shared/widgets/user_avatar.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_subpage_header.dart';  
import '../controller/profile_controller.dart';  
import '../widgets/profile_location_field.dart'; 

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key}); 

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _gardenName;
  late final TextEditingController _location;
  late final FocusNode _locationFocus;
  var _saving = false;

  ProfileController get _profile => Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    final profile = _profile;
    _name = TextEditingController(text: profile.displayName.value);
    _email = TextEditingController(text: profile.email.value);
    _gardenName = TextEditingController(text: profile.gardenName.value);
    _location = TextEditingController(text: profile.location.value);
    _locationFocus = FocusNode();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _gardenName.dispose();
    _location.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final ok = await _profile.saveProfile(
      name: _name.text,
      email: _email.text,
      gardenName: _gardenName.text,
      location: _location.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!ok) {
      CustomSnackbar.error(message: 'Check your name and email.');
      return;
    }
    NavigationHelper.back();
  }

  @override
  Widget build(BuildContext context) {
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
              GardenSubpageHeader(
                title: 'Edit Profile',
                trailing: GestureDetector(
                  onTap: _saving ? null : _save,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 6.h,
                    ),
                    child: CustomText(
                      'Save',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.medium.w,
                      AppSpacing.small.h,
                      AppSpacing.medium.w,
                      AppSpacing.large.h,
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      GardenPopIn(child: _PhotoBlock(onTap: _profile.pickPhoto)),
                      SizedBox(height: AppSpacing.large.h),
                      GardenPopIn(
                        delay: const Duration(milliseconds: 40),
                        child: CustomContainer(
                          color: AppColors.white,
                          borderRadius: AppRadius.large,
                          border: Border.all(color: AppColors.border),
                          padding: EdgeInsets.all(AppSpacing.medium.w),
                          child: Column(
                            children: [
                              _EditField(
                                label: 'Name',
                                controller: _name,
                                hint: 'Your name',
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.name],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Name is required';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.medium.h),
                              _EditField(
                                label: 'Email',
                                controller: _email,
                                hint: 'you@email.com',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                validator: (value) {
                                  final trimmed = value?.trim() ?? '';
                                  if (trimmed.isEmpty) return null;
                                  final valid = RegExp(
                                    r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$',
                                  );
                                  if (!valid.hasMatch(trimmed)) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppSpacing.medium.h),
                              _EditField(
                                label: 'Garden name',
                                controller: _gardenName,
                                hint: 'My garden',
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: AppSpacing.medium.h),
                              ProfileLocationField(
                                controller: _location,
                                focusNode: _locationFocus,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.large.h),
                      GardenPopIn(
                        delay: const Duration(milliseconds: 80),
                        child: CustomButton(
                          text: 'Save',
                          onPressed: _save,
                          isLoading: _saving,
                          backgroundColor: AppColors.primaryGreen,
                          height: 50,
                          borderRadius: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoBlock extends StatelessWidget {
  const _PhotoBlock({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const UserAvatar(size: 88, elevated: true),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 14.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const CustomText(
            'Change photo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
        ),
        SizedBox(height: 6.h),
        CustomTextField(
          controller: controller,
          hintText: hint,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          validator: validator,
          isDense: true,
          fillColor: AppColors.sageBackground,
          enabledBorderColor: AppColors.border,
          focusedBorderColor: AppColors.primaryGreen,
          cursorColor: AppColors.primaryGreen,
          borderRadius: 14,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 12.h,
          ),
        ),
      ],
    );
  }
}
