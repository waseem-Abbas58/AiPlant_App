import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../home/model/suggestion_article.dart';
import '../../home/model/trending_plant.dart';
import '../../suggestions/view/suggestion_detail_view.dart';
import '../view/identify_disease_view.dart';

class IdentifyGuideTabs {
  static const labels = [
    'Overview',
    'Requirements',
    'Culture',
    'FAQ',
    'Articles',
  ];
}

class IdentifyGuideTabBar extends StatelessWidget {
  const IdentifyGuideTabBar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.sageBackground,
      child: SizedBox(
        height: 48.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.medium.w,
            8.h,
            AppSpacing.medium.w,
            8.h,
          ),
          itemCount: IdentifyGuideTabs.labels.length,
          separatorBuilder: (_, __) => SizedBox(width: AppSpacing.small.w),
          itemBuilder: (_, index) {
            final on = index == selected;
            return CustomContainer(
              onTap: () => onSelect(index),
              color: on ? AppColors.primaryGreen : AppColors.white,
              borderRadius: AppRadius.circular,
              border: on ? null : Border.all(color: AppColors.border),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              alignment: Alignment.center,
              child: CustomText(
                IdentifyGuideTabs.labels[index],
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: on ? AppColors.white : AppColors.secondaryText,
              ),
            );
          },
        ),
      ),
    );
  }
}

class IdentifyGuidePinHeader extends SliverPersistentHeaderDelegate {
  IdentifyGuidePinHeader({
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  double get minExtent => 48.h;

  @override
  double get maxExtent => 48.h;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return IdentifyGuideTabBar(selected: selected, onSelect: onSelect);
  }

  @override
  bool shouldRebuild(IdentifyGuidePinHeader oldDelegate) {
    return oldDelegate.selected != selected;
  }
}

class IdentifyGuideSections extends StatelessWidget {
  const IdentifyGuideSections({
    super.key,
    required this.plant,
    required this.overviewKey,
    required this.requirementsKey,
    required this.cultureKey,
    required this.faqKey,
    required this.articlesKey,
    required this.overviewLead,
    required this.onWater,
    required this.onChat,
  });

  final TrendingPlant plant;
  final Key overviewKey;
  final Key requirementsKey;
  final Key cultureKey;
  final Key faqKey;
  final Key articlesKey;
  final Widget overviewLead;
  final VoidCallback onWater;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KeyedSubtree(
          key: overviewKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              overviewLead,
              SizedBox(height: AppSpacing.large.h),
              const _Label('Overview'),
              SizedBox(height: AppSpacing.small.h),
              _CardText(title: 'About', body: plant.aboutText),
              SizedBox(height: AppSpacing.small.h),
              _IconBlock(
                icon: Icons.celebration_outlined,
                title: 'Fun Fact',
                body: plant.funFact,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.large.h),
        KeyedSubtree(
          key: requirementsKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Requirements'),
              SizedBox(height: AppSpacing.small.h),
              Row(
                children: [
                  Expanded(
                    child: _Spec(title: 'Temperature', value: plant.temperature),
                  ),
                  SizedBox(width: AppSpacing.small.w),
                  Expanded(
                    child: _Spec(
                      title: 'Hardiness Zone',
                      value: plant.hardiness,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.small.h),
              _Need(
                icon: Icons.opacity_outlined,
                title: 'Water',
                value: plant.waterNote,
              ),
              SizedBox(height: AppSpacing.small.h),
              _Need(
                icon: Icons.wb_sunny_outlined,
                title: 'Sunlight',
                value: plant.lightNote,
              ),
              SizedBox(height: AppSpacing.small.h),
              _Need(
                icon: Icons.grass_outlined,
                title: 'Soil',
                value: plant.soilNote,
              ),
              SizedBox(height: AppSpacing.small.h),
              _Need(
                icon: Icons.place_outlined,
                title: 'Location',
                value: plant.placeChip,
              ),
              SizedBox(height: AppSpacing.medium.h),
              const _Label('Scientific Classifications'),
              SizedBox(height: AppSpacing.small.h),
              _ClassCard(
                rows: [
                  ('Order', plant.order),
                  ('Genus', plant.genus),
                  ('Family', plant.family),
                  ('Class', plant.taxonClass),
                ],
              ),
              SizedBox(height: AppSpacing.medium.h),
              _ToolsCard(onWater: onWater, onChat: onChat),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.large.h),
        KeyedSubtree(
          key: cultureKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Culture'),
              SizedBox(height: AppSpacing.small.h),
              _IconBlock(
                icon: Icons.menu_book_outlined,
                title: 'Name Story',
                body: plant.nameStory,
              ),
              SizedBox(height: AppSpacing.small.h),
              _IconBlock(
                icon: Icons.yard_outlined,
                title: 'Garden Use',
                body: plant.gardenUse,
              ),
              SizedBox(height: AppSpacing.small.h),
              _IconBlock(
                icon: Icons.lightbulb_outline_rounded,
                title: 'Interesting Facts',
                body: plant.interestingFacts,
              ),
              SizedBox(height: AppSpacing.small.h),
              _IconBlock(
                icon: Icons.eco_outlined,
                title: 'Symbolism',
                body: plant.symbolism,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.large.h),
        KeyedSubtree(
          key: faqKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('FAQ'),
              SizedBox(height: AppSpacing.small.h),
              _Faq(question: 'How often should I water it?', answer: plant.waterNote),
              SizedBox(height: AppSpacing.small.h),
              _Faq(question: 'What light does it need?', answer: plant.lightNote),
              SizedBox(height: AppSpacing.small.h),
              _Faq(
                question: 'Is it safe for pets and kids?',
                answer: plant.toxicity.summary,
              ),
              SizedBox(height: AppSpacing.small.h),
              _Faq(question: 'What soil should I use?', answer: plant.soilNote),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.large.h),
        KeyedSubtree(
          key: articlesKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Articles'),
              SizedBox(height: AppSpacing.small.h),
              if (plant.pests.isNotEmpty) ...[
                const CustomText(
                  'Pests and Diseases',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                SizedBox(height: AppSpacing.small.h),
                SizedBox(
                  height: 118.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: plant.pests.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(width: AppSpacing.small.w),
                    itemBuilder: (_, index) {
                      final pest = plant.pests[index];
                      return CustomContainer(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          NavigationHelper.to(
                            () => IdentifyDiseaseView(
                              imagePath: pest.imagePath,
                              plantName: plant.name,
                            ),
                          );
                        },
                        width: 96,
                        color: AppColors.white,
                        borderRadius: AppRadius.large,
                        shadow: AppShadows.soft,
                        clipBehavior: Clip.antiAlias,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.asset(
                                pest.imagePath,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6.w),
                              child: CustomText(
                                pest.title,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: AppSpacing.medium.h),
              ],
              for (final article in [
                SuggestionArticle.samples[3],
                SuggestionArticle.samples[4],
              ]) ...[
                CustomContainer(
                  onTap: () => SuggestionDetailView.open(article),
                  color: AppColors.white,
                  borderRadius: AppRadius.large,
                  shadow: AppShadows.soft,
                  padding: EdgeInsets.all(AppSpacing.small.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              article.category,
                              fontSize: 11,
                              color: AppColors.mutedText,
                            ),
                            CustomText(
                              article.title,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                              maxLines: 2,
                            ),
                            const CustomText(
                              'Go to learn >',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpacing.small.w),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.medium.r),
                        child: Image.asset(
                          article.imagePath,
                          width: 72.w,
                          height: 72.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.small.h),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

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

class _CardText extends StatelessWidget {
  const _CardText({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            body,
            fontSize: 14,
            color: AppColors.secondaryText,
            height: 1.45,
          ),
        ],
      ),
    );
  }
}

class _IconBlock extends StatelessWidget {
  const _IconBlock({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 18.sp),
              SizedBox(width: AppSpacing.small.w),
              CustomText(
                title,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            body,
            fontSize: 14,
            color: AppColors.secondaryText,
            height: 1.45,
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: const Color(0xFFF2F2F7),
      borderRadius: AppRadius.large,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
          CustomText(
            value,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ],
      ),
    );
  }
}

class _Need extends StatelessWidget {
  const _Need({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: const Color(0xFFF2F2F7),
      borderRadius: AppRadius.large,
      padding: EdgeInsets.all(AppSpacing.medium.w),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 22.sp),
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
                  value,
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium.w),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  CustomText(
                    rows[i].$1,
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                  const Spacer(),
                  CustomText(
                    rows[i].$2,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(height: 1.h, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: AppSpacing.medium.w),
          childrenPadding: EdgeInsets.fromLTRB(
            AppSpacing.medium.w,
            0,
            AppSpacing.medium.w,
            AppSpacing.medium.h,
          ),
          iconColor: AppColors.primaryGreen,
          collapsedIconColor: AppColors.mutedText,
          title: CustomText(
            question,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
          children: [
            CustomText(
              answer,
              fontSize: 13,
              color: AppColors.secondaryText,
              height: 1.45,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolsCard extends StatelessWidget {
  const _ToolsCard({required this.onWater, required this.onChat});

  final VoidCallback onWater;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      shadow: AppShadows.soft,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ColoredBox(
            color: AppColors.primaryGreen,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.medium.w),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Our Tools',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    CustomText(
                      'Care tools for this plant',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            onTap: onWater,
            leading: Icon(Icons.opacity_outlined, color: AppColors.blue),
            title: const CustomText(
              'Water Meter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            subtitle: const CustomText(
              'Calculate your plants’ water needs',
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
            trailing: const CustomText(
              'Use',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          Divider(height: 1.h, color: AppColors.divider),
          ListTile(
            onTap: onChat,
            leading: Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppColors.primaryGreen,
            ),
            title: const CustomText(
              'Ask Botanist',
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            subtitle: const CustomText(
              'Get advice from expert',
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
            trailing: const CustomText(
              'Use',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
