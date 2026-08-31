import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../home/model/suggestion_article.dart';

class SuggestionDetailView extends StatefulWidget {
  const SuggestionDetailView({
    super.key,
    required this.article,
    this.heroTag,
  });

  final SuggestionArticle article;
  final String? heroTag;

  static void open(SuggestionArticle article, {String? heroTag}) {
    HapticFeedback.selectionClick();
    NavigationHelper.to(
      () => SuggestionDetailView(article: article, heroTag: heroTag),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  @override
  State<SuggestionDetailView> createState() => _SuggestionDetailViewState();
}

class _SuggestionDetailViewState extends State<SuggestionDetailView> {
  final _sheet = DraggableScrollableController();
  var _minSize = 0.4;
  var _closing = false;

  SuggestionArticle get article => widget.article;

  @override
  void initState() {
    super.initState();
    _sheet.addListener(_onSheet);
  }

  @override
  void dispose() {
    _sheet.removeListener(_onSheet);
    _sheet.dispose();
    super.dispose();
  }

  void _onSheet() {
    if (_closing || !_sheet.isAttached) return;
    if (_sheet.size > _minSize + 0.01) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      NavigationHelper.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final overlap = 28.h;
    final headerHeight = 0.42.sh;
    final sheetRest = ((media.height - headerHeight + overlap) / media.height)
        .clamp(0.52, 0.64)
        .toDouble();
    _minSize = (sheetRest - 0.14).clamp(0.36, sheetRest - 0.05);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerHeight,
              child: Hero(
                tag: widget.heroTag ?? article.imagePath,
                child: Image.asset(
                  article.imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: headerHeight,
                ),
              ),
            ),
            DraggableScrollableSheet(
              controller: _sheet,
              initialChildSize: sheetRest,
              minChildSize: _minSize,
              maxChildSize: 1,
              snap: true,
              snapSizes: [sheetRest, 1],
              builder: (context, scrollController) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.extraLarge.r),
                    ),
                    boxShadow: AppShadows.medium,
                  ),
                  child: ListView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.large.w,
                      0,
                      AppSpacing.large.w,
                      AppSpacing.extraLarge.h,
                    ),
                    children: [
                      _sheetHandle(),
                      CustomText(
                        article.category,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                      SizedBox(height: AppSpacing.small.h),
                      CustomText(
                        article.title,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        height: 1.25,
                      ),
                      SizedBox(height: AppSpacing.medium.h),
                      Divider(color: AppColors.divider, height: 1.h),
                      SizedBox(height: AppSpacing.medium.h),
                      for (final section in article.sections) ...[
                        CustomText(
                          section.heading,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                        SizedBox(height: AppSpacing.small.h),
                        for (final paragraph in section.paragraphs) ...[
                          CustomText(
                            paragraph,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondaryText,
                            height: 1.5,
                          ),
                          SizedBox(height: AppSpacing.medium.h),
                        ],
                        if (section.steps.isNotEmpty) ...[
                          ..._stepRows(section.steps),
                          SizedBox(height: AppSpacing.medium.h),
                        ],
                        if (section.bullets.isNotEmpty) ...[
                          ..._bulletRows(section.bullets),
                          SizedBox(height: AppSpacing.medium.h),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.medium.w),
                  child: GestureDetector(
                    onTap: NavigationHelper.back,
                    behavior: HitTestBehavior.opaque,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      child: SizedBox(
                        width: 36.r,
                        height: 36.r,
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.secondaryText,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.small.h),
      child: Center(
        child: Container(
          width: 36.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(AppRadius.circular),
          ),
        ),
      ),
    );
  }

  static List<Widget> _bulletRows(List<String> items) {
    return [
      for (var i = 0; i < items.length; i++) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 7.h),
              child: CustomContainer(
                width: 6,
                height: 6,
                color: AppColors.primaryGreen,
                borderRadius: AppRadius.circular,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: CustomText(
                items[i],
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
            ),
          ],
        ),
        if (i < items.length - 1) SizedBox(height: AppSpacing.small.h),
      ],
    ];
  }

  static List<Widget> _stepRows(List<String> steps) {
    return [
      for (var i = 0; i < steps.length; i++) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomContainer(
              width: 24,
              height: 24,
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: AppRadius.circular,
              alignment: Alignment.center,
              child: CustomText(
                '${i + 1}',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: CustomText(
                  steps[i],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        if (i < steps.length - 1) SizedBox(height: AppSpacing.medium.h),
      ],
    ];
  }
}
