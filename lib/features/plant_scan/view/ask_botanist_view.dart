import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/custom_text_field.dart';

class _ChatLine {
  const _ChatLine({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;
}

class AskBotanistView extends StatefulWidget {
  const AskBotanistView({
    super.key,
    this.plantName = '',
    this.imagePath,
    this.isAssetImage = false,
  });

  final String plantName;
  final String? imagePath;
  final bool isAssetImage;

  @override
  State<AskBotanistView> createState() => _AskBotanistViewState();
}

class _AskBotanistViewState extends State<AskBotanistView> {
  late final TextEditingController _controller;
  late final List<_ChatLine> _lines;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    final name = widget.plantName.trim().isEmpty
        ? 'your plant'
        : widget.plantName.trim();
    _lines = [
      _ChatLine(
        text:
            'Ask anything about $name. A botanist reply will appear here when AI is connected.',
        fromUser: false,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _lines.add(_ChatLine(text: text, fromUser: true));
      _lines.add(
        const _ChatLine(
          text: 'A botanist reply will appear here when AI is connected.',
          fromUser: false,
        ),
      );
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.sageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.sageBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: NavigationHelper.back,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: AppColors.primaryText,
            ),
          ),
          title: Column(
            children: [
              const CustomText(
                'Ask Botanist',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
              if (widget.plantName.trim().isNotEmpty)
                CustomText(
                  widget.plantName.trim(),
                  fontSize: 12,
                  color: AppColors.secondaryText,
                ),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            if (widget.imagePath != null && widget.imagePath!.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  0,
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.medium.r),
                    child: widget.isAssetImage
                        ? Image.asset(
                            widget.imagePath!,
                            width: 56.w,
                            height: 56.w,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(widget.imagePath!),
                            width: 56.w,
                            height: 56.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: AppColors.divider,
                              child: SizedBox(width: 56.w, height: 56.w),
                            ),
                          ),
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                  AppSpacing.medium.w,
                  AppSpacing.medium.h,
                ),
                itemCount: _lines.length,
                separatorBuilder: (_, __) => SizedBox(height: AppSpacing.small.h),
                itemBuilder: (context, index) {
                  final line = _lines[index];
                  return Align(
                    alignment: line.fromUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: CustomContainer(
                      color: line.fromUser
                          ? AppColors.primaryGreen
                          : AppColors.white,
                      borderRadius: AppRadius.large,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      constraints: BoxConstraints(maxWidth: 280.w),
                      child: CustomText(
                        line.text,
                        fontSize: 14,
                        height: 1.4,
                        color: line.fromUser
                            ? AppColors.white
                            : AppColors.primaryText,
                      ),
                    ),
                  );
                },
              ),
            ),
            CustomContainer(
              color: AppColors.white,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.medium.w,
                AppSpacing.small.h,
                AppSpacing.small.w,
                AppSpacing.small.h + bottom,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _controller,
                      hintText: 'Ask about this plant…',
                      fillColor: AppColors.sageBackground,
                      focusedBorderColor: AppColors.primaryGreen,
                      cursorColor: AppColors.primaryGreen,
                      borderRadius: AppRadius.circular,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  SizedBox(width: AppSpacing.small.w),
                  CustomContainer(
                    onTap: _send,
                    width: 44,
                    height: 44,
                    color: AppColors.primaryGreen,
                    borderRadius: AppRadius.circular,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.send_rounded,
                      size: 18.sp,
                      color: AppColors.white,
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
