import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_shadows.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_image.dart';
import '../../../shared/widgets/custom_text.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../my_garden/widgets/garden_plant_image.dart';
import '../../my_garden/widgets/garden_pop_in.dart';
import '../../my_garden/widgets/garden_sheet.dart';
import '../controller/chatbot_controller.dart';
import '../data/botanist_chat.dart';
import '../model/chat_message.dart';
import '../view/botanist_call_view.dart';
import '../widgets/botanist_rich_reply.dart';
import '../widgets/chat_history_drawer.dart';
import '../widgets/chat_plant_picker_sheet.dart';
import '../widgets/chat_typing_dots.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final composerBottom = keyboardOpen
        ? AppSpacing.small.h
        : MediaQuery.paddingOf(context).bottom + AppSpacing.small.h;

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
          bottom: false,
          child: Column(
            children: [
              const _ChatHeader(),
              const _FindInChatBar(),
              Obx(() {
                final plant = controller.plantContext.value;
                if (plant == null) return const SizedBox.shrink();
                return _PlantContextBar(
                  plant: plant,
                  onClear: controller.clearPlantContext,
                );
              }),
              Expanded(
                child: Obx(() {
                  if (!controller.hasThread) {
                    return _ChatEmpty(
                      plant: controller.plantContext.value,
                      onHint: controller.sendHint,
                      onPickPlant: () => _pickPlant(context),
                    );
                  }
                  controller.findQuery.value;
                  controller.findHitIndex.value;
                  controller.findHits.length;
                  return ListView.separated(
                    controller: controller.scrollController,
                    reverse: true,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.medium.w,
                      AppSpacing.medium.h,
                      AppSpacing.medium.w,
                      AppSpacing.small.h,
                    ),
                    itemCount: controller.messages.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSpacing.small.h),
                    itemBuilder: (context, index) {
                      final message = controller.messages[
                          controller.messages.length - 1 - index];
                      return _ChatBubble(message: message);
                    },
                  );
                }),
              ),
              _Composer(
                bottom: composerBottom,
                onAttach: () => _attachSheet(context),
                onCamera: () =>
                    controller.attachPhoto(ImageSource.camera),
                onCall: openBotanistCall,
              ),
            ],
          ),
                          ),
                        ),
                      );
  }

  Future<void> _pickPlant(BuildContext context) async {
    final plants = controller.gardenPlants();
    if (plants.isEmpty) {
      controller.showEmptyGardenHint();
      return;
    }
    final plant = await showChatPlantPicker(context, plants: plants);
    if (plant == null) return;
    controller.pickGardenPlant(plant);
  }

  Future<void> _attachSheet(BuildContext context) {
    return showGardenSheet<void>(
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
              SizedBox(height: AppSpacing.small.h),
              _AttachRow(
                icon: Icons.photo_camera_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  controller.attachPhoto(ImageSource.camera);
                },
              ),
              Divider(color: AppColors.divider, height: 1.h),
              _AttachRow(
                icon: Icons.photo_outlined,
                label: 'Gallery',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  controller.attachPhoto(ImageSource.gallery);
                },
              ),
              Divider(color: AppColors.divider, height: 1.h),
              _AttachRow(
                icon: Icons.description_outlined,
                label: 'Document',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  controller.attachDocument();
                },
              ),
              Divider(color: AppColors.divider, height: 1.h),
              _AttachRow(
                icon: Icons.local_florist_outlined,
                label: 'Plant from garden',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickPlant(context);
                },
              ),
              SizedBox(height: AppSpacing.medium.h),
              const CustomText(
                'Stickers',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
              SizedBox(height: AppSpacing.small.h),
              Wrap(
                spacing: AppSpacing.small.w,
                runSpacing: AppSpacing.small.h,
                children: [
                  for (final sticker in BotanistChat.stickers)
              CustomContainer(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(sheetContext).pop();
                        controller.sendSticker(sticker);
                      },
                      width: 44,
                      height: 44,
                      color: AppColors.sageBackground,
                      borderRadius: AppRadius.medium,
                      alignment: Alignment.center,
                      child: CustomText(sticker, fontSize: 22),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatHeader extends GetView<ChatbotController> {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.medium.w,
                  AppSpacing.small.h,
                  AppSpacing.small.w,
        AppSpacing.small.h,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Chat history',
            onPressed: () {
              HapticFeedback.selectionClick();
              showChatHistoryDrawer(context);
            },
            icon: Icon(
              Icons.menu_rounded,
              color: AppColors.primaryText,
              size: 24.sp,
            ),
          ),
          const Expanded(
            child: CustomText(
              'Ask Botanist',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.6,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'New chat',
            onPressed: () {
              HapticFeedback.selectionClick();
              controller.newChat();
            },
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.primaryGreen,
              size: 22.sp,
            ),
          ),
          IconButton(
            tooltip: 'Chat options',
            onPressed: () {
              HapticFeedback.selectionClick();
              _openChatMenu(context);
            },
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppColors.primaryText,
              size: 22.sp,
            ),
          ),
        ],
      ),
    );
  }

  void _openChatMenu(BuildContext context) {
    showGardenSheet<void>(
      context: context,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.large.w,
            AppSpacing.small.h,
            AppSpacing.large.w,
            AppSpacing.large.h + MediaQuery.paddingOf(sheetContext).bottom,
          ),
          child: Obx(() {
            final pinned = controller.activePinned;
            final archived = controller.activeArchived;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomContainer(
                  width: 36,
                  height: 4,
                  color: AppColors.divider,
                  borderRadius: AppRadius.circular,
                ),
                SizedBox(height: AppSpacing.small.h),
                _ChatMenuRow(
                  icon: pinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  label: pinned ? 'Unpin' : 'Pin',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.togglePin();
                  },
                ),
                Divider(color: AppColors.divider, height: 1.h),
                _ChatMenuRow(
                  icon: Icons.search_rounded,
                  label: 'Find in chat',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.openFind();
                  },
                ),
                Divider(color: AppColors.divider, height: 1.h),
                _ChatMenuRow(
                  icon: Icons.inventory_2_outlined,
                  label: archived ? 'Unarchive' : 'Archive',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    controller.toggleArchive();
                  },
                ),
                Divider(color: AppColors.divider, height: 1.h),
                _ChatMenuRow(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _confirmDelete(context);
                  },
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete this chat?'),
          content: const Text('This chat will be removed from history.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (ok == true) controller.deleteActive();
  }
}

class _FindInChatBar extends GetView<ChatbotController> {
  const _FindInChatBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.finding.value) return const SizedBox.shrink();
      final hits = controller.findHits.length;
      final index = controller.findHitIndex.value;
      final label = hits == 0
          ? 'No matches'
          : '${index + 1} of $hits';
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.medium.w,
          0,
          AppSpacing.small.w,
          AppSpacing.small.h,
        ),
        child: CustomContainer(
          color: AppColors.white,
          borderRadius: AppRadius.large,
          padding: EdgeInsets.fromLTRB(4.w, 4.h, 4.w, 4.h),
                child: Row(
                  children: [
              IconButton(
                tooltip: 'Close find',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  controller.closeFind();
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 20.sp,
                  color: AppColors.secondaryText,
                ),
              ),
                    Expanded(
                child: TextField(
                  controller: controller.findController,
                  focusNode: controller.findFocus,
                        cursorColor: AppColors.primaryGreen,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.primaryText,
                    height: 1.2,
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: controller.setFindQuery,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Find in chat',
                    hintStyle: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.mutedText,
                    ),
                  ),
                ),
              ),
              CustomText(
                label,
                fontSize: 12,
                color: AppColors.mutedText,
              ),
              IconButton(
                tooltip: 'Previous',
                onPressed: hits == 0
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        controller.findStep(-1);
                      },
                icon: Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 22.sp,
                  color: hits == 0
                      ? AppColors.mutedText
                      : AppColors.primaryText,
                ),
              ),
              IconButton(
                tooltip: 'Next',
                onPressed: hits == 0
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        controller.findStep(1);
                      },
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.sp,
                  color: hits == 0
                      ? AppColors.mutedText
                      : AppColors.primaryText,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ChatMenuRow extends StatelessWidget {
  const _ChatMenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primaryText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: onTap,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.medium.h),
      child: Row(
        children: [
          Icon(icon, size: 22.sp, color: color),
          SizedBox(width: AppSpacing.medium.w),
          CustomText(
            label,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _PlantContextBar extends StatelessWidget {
  const _PlantContextBar({
    required this.plant,
    required this.onClear,
  });

  final ChatPlantContext plant;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * -8),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.medium.w,
          0,
          AppSpacing.medium.w,
          AppSpacing.small.h,
        ),
        child: CustomContainer(
          color: AppColors.white,
          borderRadius: AppRadius.large,
          shadow: AppShadows.soft,
          padding: EdgeInsets.fromLTRB(10.w, 8.h, 6.w, 8.h),
          child: Row(
            children: [
              if (plant.hasPhoto)
                GardenPlantImage(
                  path: plant.imagePath!,
                  isAsset: plant.isAssetImage,
                  width: 40.w,
                  height: 40.w,
                  borderRadius: BorderRadius.circular(AppRadius.medium.r),
                )
              else
                    CustomContainer(
                  width: 40,
                  height: 40,
                  color: AppColors.sageBackground,
                  borderRadius: AppRadius.medium,
                      alignment: Alignment.center,
                      child: Icon(
                    Icons.local_florist_outlined,
                    color: AppColors.primaryGreen,
                    size: 20.sp,
                  ),
                ),
              SizedBox(width: AppSpacing.small.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      'Talking about',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedText,
                    ),
                    CustomText(
                      plant.name,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Clear plant',
                onPressed: onClear,
                icon: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatEmpty extends StatelessWidget {
  const _ChatEmpty({
    required this.plant,
    required this.onHint,
    required this.onPickPlant,
  });

  final ChatPlantContext? plant;
  final ValueChanged<ChatHint> onHint;
  final VoidCallback onPickPlant;

  @override
  Widget build(BuildContext context) {
    final name = plant?.name;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium.w,
        AppSpacing.large.h,
        AppSpacing.medium.w,
        AppSpacing.medium.h,
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.86, end: 1),
            duration: const Duration(milliseconds: 480),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: CustomContainer(
              width: 72,
              height: 72,
              color: AppColors.white,
              borderRadius: AppRadius.circular,
              shadow: AppShadows.soft,
              alignment: Alignment.center,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primaryGreen,
                size: 30.sp,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.medium.h),
          CustomText(
            name == null ? 'Plant care, instantly' : 'Ask about $name',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            textAlign: TextAlign.center,
            letterSpacing: -0.3,
          ),
          SizedBox(height: AppSpacing.small.h),
          CustomText(
            name == null
                ? 'Tap a hint, pick a garden plant, or attach a photo.'
                : 'Watering, light, yellow leaves, pests — tap a hint to start.',
            fontSize: 14,
            color: AppColors.secondaryText,
            textAlign: TextAlign.center,
            height: 1.4,
          ),
          SizedBox(height: AppSpacing.large.h),
          LayoutBuilder(
            builder: (context, constraints) {
              const radius = 14.0;
              final gap = AppSpacing.small.w;
              final chipW = (constraints.maxWidth - gap * 2) / 3;
              final chipH = 32.w;
              final hints = BotanistChat.hints;
              Widget chip(int i) {
                return GardenPopIn(
                  delay: Duration(milliseconds: 50 * i),
                  child: SizedBox(
                    width: chipW,
                    height: chipH,
                    child: CustomContainer(
                      onTap: () => onHint(hints[i]),
                      color: AppColors.white,
                      borderRadius: radius,
                      alignment: Alignment.center,
                      border: Border.all(color: AppColors.border),
                      child: CustomText(
                        hints[i].label,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      chip(0),
                      SizedBox(width: gap),
                      chip(1),
                      SizedBox(width: gap),
                      chip(2),
                    ],
                  ),
                  SizedBox(height: gap),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      chip(3),
                      SizedBox(width: gap),
                      chip(4),
                    ],
                  ),
                ],
              );
            },
          ),
          if (name == null) ...[
            SizedBox(height: AppSpacing.large.h),
            CustomContainer(
              onTap: onPickPlant,
              color: AppColors.white,
              borderRadius: AppRadius.large,
              shadow: AppShadows.soft,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.medium.w,
                vertical: 14.h,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_florist_outlined,
                    color: AppColors.primaryGreen,
                    size: 22.sp,
                  ),
                  SizedBox(width: AppSpacing.small.w),
                  const Expanded(
                    child: CustomText(
                      'Pick a plant from your garden',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.mutedText,
                    size: 22.sp,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;
    return KeyedSubtree(
      key: GlobalObjectKey(message.id),
      child: TweenAnimationBuilder<double>(
      key: ValueKey(message.id),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              (fromUser ? 12 : -12) * (1 - value),
              8 * (1 - value),
            ),
            child: child,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                fromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!fromUser) ...[
                const _BotanistAvatar(),
                SizedBox(width: 8.w),
              ],
              Flexible(
                child: message.isTyping || !message.hasPhoto
                    ? fromUser
                        ? CustomContainer(
                            color: AppColors.primaryGreen,
                            borderRadius: AppRadius.large,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 10.h,
                            ),
                            constraints: BoxConstraints(maxWidth: 248.w),
                            child: _TextBubbleBody(message: message),
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                              right: 12.w,
                              top: 2.h,
                              bottom: 2.h,
                            ),
                            child: message.isTyping
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 6.h,
                                      horizontal: 2.w,
                                    ),
                                    child: const ChatTypingDots(),
                                  )
                                : _TextBubbleBody(message: message),
                          )
                    : _PhotoCard(message: message),
              ),
              if (fromUser) ...[
                SizedBox(width: 8.w),
                const _UserAvatar(),
              ],
            ],
          ),
          if (_showReplyActions(message))
            Padding(
              padding: EdgeInsets.only(left: 40.w, top: 2.h),
              child: _ReplyActions(message: message),
            ),
        ],
      ),
      ),
    );
  }
}

bool _showReplyActions(ChatMessage message) {
  if (message.fromUser || message.isTyping || message.hasFile) return false;
  final text = message.text.trim();
  if (text.isEmpty) return false;
  return !_isStickerText(text);
}

bool _isStickerText(String text) {
  final trimmed = text.trim();
  return trimmed.isNotEmpty && !RegExp(r'[A-Za-z0-9]').hasMatch(trimmed);
}

class _FindAwareText extends StatelessWidget {
  const _FindAwareText({
    required this.text,
    required this.messageId,
    required this.color,
    this.fontSize = 14,
    this.height = 1.4,
    this.maxLines,
    this.onUserBubble = false,
  });

  final String text;
  final String messageId;
  final Color color;
  final double fontSize;
  final double height;
  final int? maxLines;
  final bool onUserBubble;

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<ChatbotController>();
    final query = chat.findQuery.value.trim();
    if (query.isEmpty) {
      return CustomText(
        text,
        fontSize: fontSize,
        height: height,
        color: color,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
      );
    }

    final active = chat.findHits.isEmpty
        ? null
        : chat.findHits[chat.findHitIndex.value];
    final needle = query.toLowerCase();
    final lower = text.toLowerCase();
    final spans = <InlineSpan>[];
    var from = 0;
    while (from < text.length) {
      final at = lower.indexOf(needle, from);
      if (at < 0) {
        spans.add(TextSpan(text: text.substring(from)));
        break;
      }
      if (at > from) {
        spans.add(TextSpan(text: text.substring(from, at)));
      }
      final end = at + needle.length;
      final isActive = active != null &&
          active.messageId == messageId &&
          active.start == at;
      final fill = onUserBubble
          ? (isActive
              ? AppColors.white.withValues(alpha: 0.35)
              : AppColors.white.withValues(alpha: 0.16))
          : (isActive
              ? AppColors.lightGreen.withValues(alpha: 0.90)
              : AppColors.lightGreen.withValues(alpha: 0.38));
      spans.add(
        TextSpan(
          text: text.substring(at, end),
          style: TextStyle(
            backgroundColor: fill,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      );
      from = end;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize.sp,
        height: height,
        color: color,
      ),
    );
  }
}

class _ReplyActions extends StatefulWidget {
  const _ReplyActions({required this.message});

  final ChatMessage message;

  @override
  State<_ReplyActions> createState() => _ReplyActionsState();
}

class _ReplyActionsState extends State<_ReplyActions> {
  bool _copied = false;

  ChatbotController get _chat => Get.find<ChatbotController>();

  Future<void> _copy() async {
    HapticFeedback.selectionClick();
    await _chat.copyReply(widget.message);
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.message.mood;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ReplyActionButton(
          icon: _copied ? Icons.check_rounded : Icons.content_copy_rounded,
          color: _copied ? AppColors.primaryGreen : AppColors.mutedText,
          tooltip: 'Copy',
          onTap: _copy,
        ),
        _ReplyActionButton(
          icon: mood == ChatReplyMood.good
              ? Icons.thumb_up_alt_rounded
              : Icons.thumb_up_alt_outlined,
          color: mood == ChatReplyMood.good
              ? AppColors.primaryGreen
              : AppColors.mutedText,
          tooltip: 'Good',
          onTap: () {
            HapticFeedback.selectionClick();
            _chat.rateReply(widget.message.id, ChatReplyMood.good);
          },
        ),
        _ReplyActionButton(
          icon: mood == ChatReplyMood.bad
              ? Icons.thumb_down_alt_rounded
              : Icons.thumb_down_alt_outlined,
          color: mood == ChatReplyMood.bad
              ? AppColors.error
              : AppColors.mutedText,
          tooltip: 'Bad',
          onTap: () {
            HapticFeedback.selectionClick();
            _chat.rateReply(widget.message.id, ChatReplyMood.bad);
          },
        ),
        _ReplyActionButton(
          icon: Icons.ios_share_rounded,
          color: AppColors.mutedText,
          tooltip: 'Share',
          onTap: () {
            HapticFeedback.selectionClick();
            _chat.shareReply(widget.message);
          },
        ),
      ],
    );
  }
}

class _ReplyActionButton extends StatelessWidget {
  const _ReplyActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 34.w,
          height: 34.w,
          child: Icon(icon, size: 18.sp, color: color),
        ),
      ),
    );
  }
}

class _TextBubbleBody extends StatelessWidget {
  const _TextBubbleBody({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser;
    if (message.hasFile) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description_outlined,
            size: 20.sp,
            color: fromUser ? AppColors.white : AppColors.primaryGreen,
          ),
          SizedBox(width: AppSpacing.small.w),
          Flexible(
            child: CustomText(
              message.fileName!,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fromUser ? AppColors.white : AppColors.primaryText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    if (message.text.isEmpty) return const SizedBox.shrink();
    final sticker = _isStickerText(message.text);
    if (sticker) {
      return CustomText(
        message.text,
        fontSize: 28,
        height: 1.1,
        color: fromUser ? AppColors.white : AppColors.primaryText,
      );
    }
    if (fromUser) {
      return _FindAwareText(
        text: message.text,
        messageId: message.id,
        fontSize: 14,
        height: 1.4,
        color: AppColors.white,
        onUserBubble: true,
      );
    }
    return BotanistRichReply(
      text: message.text,
      messageId: message.id,
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final caption = message.text.trim();
    final width = 236.w;
    final imageHeight = 158.w;
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: AppShadows.soft,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GardenPlantImage(
            path: message.imagePath!,
            isAsset: message.isAssetImage,
            width: width,
            height: imageHeight,
          ),
          if (caption.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 10.w),
              child: _FindAwareText(
                text: caption,
                messageId: message.id,
                fontSize: 13,
                height: 1.3,
                color: AppColors.primaryText,
                maxLines: 3,
              ),
            ),
        ],
      ),
    );
  }
}

class _BotanistAvatar extends StatelessWidget {
  const _BotanistAvatar();

  @override
  Widget build(BuildContext context) {
    return CustomImage(
      assetPath: 'assets/images/ask_botanist.png',
      width: 32,
      height: 32,
      fit: BoxFit.cover,
      borderRadius: AppRadius.circular,
      semanticsLabel: 'Ask Botanist',
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar();

  @override
  Widget build(BuildContext context) {
    return const UserAvatar(size: 32);
  }
}

class _Composer extends StatefulWidget {
  const _Composer({
    required this.bottom,
    required this.onAttach,
    required this.onCamera,
    required this.onCall,
  });

  final double bottom;
  final VoidCallback onAttach;
  final VoidCallback onCamera;
  final VoidCallback onCall;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  late final ChatbotController _chat;

  @override
  void initState() {
    super.initState();
    _chat = Get.find<ChatbotController>();
    _chat.inputFocus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _chat.inputFocus.removeListener(_onFocus);
    super.dispose();
  }

  void _onFocus() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final focused = _chat.inputFocus.hasFocus;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        10.w,
        6.h,
        10.w,
        6.h + widget.bottom,
      ),
      child: Obx(() {
        final listening = _chat.isListening.value;
        final showSend = _chat.canSend && !listening;
        final pendingPath = _chat.pendingImagePath.value;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pendingPath != null && pendingPath.trim().isNotEmpty)
              _PendingPhotoChip(
                path: pendingPath,
                onClear: _chat.clearPendingPhoto,
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    constraints: BoxConstraints(
                      minHeight: 48.w,
                      maxHeight: 132.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: focused || listening
                            ? AppColors.lightGreen
                            : AppColors.border,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 16.w),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _chat.inputFocus.requestFocus(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: TextField(
                                controller: _chat.inputController,
                                focusNode: _chat.inputFocus,
                                cursorColor: AppColors.primaryGreen,
                                cursorHeight: 18.w,
                                minLines: 1,
                                maxLines: 5,
                                keyboardType: TextInputType.multiline,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.primaryText,
                                  height: 1.25,
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  isDense: true,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  hintText: listening
                                      ? 'Listening…'
                                      : pendingPath != null &&
                                              pendingPath.trim().isNotEmpty
                                          ? 'Add a caption…'
                                          : 'Ask Botanist',
                                  hintStyle: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.mutedText,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _ComposerIcon(
                          icon: listening
                              ? Icons.stop_rounded
                              : Icons.mic_none_rounded,
                          color: listening
                              ? AppColors.error
                              : AppColors.secondaryText,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _chat.toggleVoice();
                          },
                        ),
                        _ComposerIcon(
                          icon: Icons.photo_outlined,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onAttach();
                          },
                        ),
                        _ComposerIcon(
                          icon: Icons.photo_camera_outlined,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onCamera();
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 2.w, right: 4.w),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              if (showSend) {
                                _chat.send();
                              } else {
                                widget.onCall();
                              }
                            },
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: showSend
                                    ? AppColors.primaryGreen
                                    : AppColors.blue,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                showSend
                                    ? Icons.send_rounded
                                    : Icons.graphic_eq_rounded,
                                size: showSend ? 16.sp : 18.sp,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _PendingPhotoChip extends StatelessWidget {
  const _PendingPhotoChip({
    required this.path,
    required this.onClear,
  });

  final String path;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 8.h),
      child: SizedBox(
        width: 64.w,
        height: 64.w,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            GardenPlantImage(
              path: path,
              isAsset: false,
              width: 64.w,
              height: 64.w,
              borderRadius: BorderRadius.circular(AppRadius.medium.r),
            ),
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onClear();
                },
                child: Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryText,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.close_rounded,
                    size: 12.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerIcon extends StatelessWidget {
  const _ComposerIcon({
    required this.icon,
    required this.onTap,
    this.color = AppColors.secondaryText,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Icon(icon, size: 20.sp, color: color), 
      ),
    );
  }
}

class _AttachRow extends StatelessWidget {
  const _AttachRow({
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
