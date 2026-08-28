import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/helpers/navigation_helper.dart';
import '../../../shared/widgets/custom_container.dart';
import '../../../shared/widgets/custom_text.dart';
import '../controller/chatbot_controller.dart';
import '../model/chat_message.dart';

Future<void> showChatHistoryDrawer(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: 'Chat history',
    barrierColor: const Color(0x52000000),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (context, _, __) {
      final size = MediaQuery.sizeOf(context);
      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: size.width * 0.82,
            height: size.height,
            child: const _ChatHistoryPanel(),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final slide = Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

class _ChatHistoryPanel extends StatefulWidget {
  const _ChatHistoryPanel();

  @override
  State<_ChatHistoryPanel> createState() => _ChatHistoryPanelState();
}

class _ChatHistoryPanelState extends State<_ChatHistoryPanel> {
  final TextEditingController _search = TextEditingController();
  late final ChatbotController _chat;

  @override
  void initState() {
    super.initState();
    _chat = Get.find<ChatbotController>();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.sageBackground,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.medium.w,
            AppSpacing.small.h,
            AppSpacing.small.w,
            AppSpacing.medium.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: CustomText(
                      'Ask Botanist',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      letterSpacing: -0.3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: NavigationHelper.back,
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.secondaryText,
                      size: 22.sp,
                    ),
                  ),
                ],
              ),
              CustomContainer(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _chat.newChat();
                  NavigationHelper.back();
                },
                color: AppColors.white,
                borderRadius: AppRadius.large,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium.w,
                  vertical: 12.h,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryGreen,
                      size: 20.sp,
                    ),
                    SizedBox(width: AppSpacing.small.w),
                    const CustomText(
                      'New chat',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.small.h),
              _HistorySearchField(
                controller: _search,
                onClear: () => _search.clear(),
              ),
              SizedBox(height: AppSpacing.medium.h),
              Expanded(
                child: Obx(() {
                  final groups = _chat.historyGroups(_search.text);
                  if (_chat.recents.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: CustomText(
                        'No chats yet. Ask a plant question to start.',
                        fontSize: 14,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    );
                  }
                  final empty = groups.pinned.isEmpty &&
                      groups.recents.isEmpty &&
                      groups.archived.isEmpty;
                  if (empty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: CustomText(
                        'No chats match',
                        fontSize: 14,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    );
                  }
                  return ListView(
                    children: [
                      ..._section(
                        label: 'Pinned',
                        threads: groups.pinned,
                      ),
                      ..._section(
                        label: 'Recents',
                        threads: groups.recents,
                        padded: groups.pinned.isNotEmpty,
                      ),
                      ..._section(
                        label: 'Archive',
                        threads: groups.archived,
                        padded: groups.pinned.isNotEmpty ||
                            groups.recents.isNotEmpty,
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

  List<Widget> _section({
    required String label,
    required List<ChatThread> threads,
    bool padded = false,
  }) {
    if (threads.isEmpty) return const [];
    return [
      if (padded) SizedBox(height: AppSpacing.medium.h),
      _HistorySectionLabel(label),
      SizedBox(height: AppSpacing.small.h),
      for (var i = 0; i < threads.length; i++) ...[
        if (i > 0) SizedBox(height: AppSpacing.small.h),
        _HistoryRow(
          thread: threads[i],
          selected: threads[i].id == _chat.activeThreadId.value,
          onTap: () {
            _chat.openThread(threads[i]);
            NavigationHelper.back();
          },
          onDelete: () => _chat.deleteThread(threads[i].id),
        ),
      ],
    ];
  }
}

class _HistorySearchField extends StatelessWidget {
  const _HistorySearchField({
    required this.controller,
    required this.onClear,
  });

  final TextEditingController controller;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasQuery = controller.text.trim().isNotEmpty;
    return CustomContainer(
      color: AppColors.white,
      borderRadius: AppRadius.large,
      padding: EdgeInsets.fromLTRB(12.w, 0, 4.w, 0),
      child: SizedBox(
        height: 44.w,
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 20.sp,
              color: AppColors.mutedText,
            ),
            SizedBox(width: AppSpacing.small.w),
            Expanded(
              child: TextField(
                controller: controller,
                cursorColor: AppColors.primaryGreen,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.primaryText,
                  height: 1.2,
                ),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  isCollapsed: true,
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Search chats',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            ),
            if (hasQuery)
              IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onClear();
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: AppColors.mutedText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HistorySectionLabel extends StatelessWidget {
  const _HistorySectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      label,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.mutedText,
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.thread,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final ChatThread thread;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      color: selected ? AppColors.white : Colors.transparent,
      borderRadius: AppRadius.large,
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 4.w, 10.h),
      child: Row(
        children: [
          Icon(
            thread.archived
                ? Icons.inventory_2_outlined
                : thread.pinned
                    ? Icons.push_pin_rounded
                    : Icons.chat_bubble_outline_rounded,
            size: 18.sp,
            color: selected
                ? AppColors.primaryGreen
                : thread.archived
                    ? AppColors.mutedText
                    : AppColors.secondaryText,
          ),
          SizedBox(width: AppSpacing.small.w),
          Expanded(
            child: CustomText(
              thread.title,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: thread.archived
                  ? AppColors.mutedText
                  : AppColors.primaryText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Delete chat',
            onPressed: () {
              HapticFeedback.selectionClick();
              onDelete();
            },
            icon: Icon(
              Icons.close_rounded,
              size: 18.sp,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
