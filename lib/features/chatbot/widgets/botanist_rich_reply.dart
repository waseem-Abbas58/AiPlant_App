import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controller/chatbot_controller.dart';

class BotanistRichReply extends StatelessWidget {
  const BotanistRichReply({
    super.key,
    required this.text,
    required this.messageId,
  });

  final String text;
  final String messageId;

  @override
  Widget build(BuildContext context) {
    final chat = Get.find<ChatbotController>();
    final blocks = _parseBlocks(text);
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      chat.findQuery.value;
      chat.findHitIndex.value;
      chat.findHits.length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < blocks.length; i++)
            _BlockView(
              block: blocks[i],
              isFirst: i == 0,
              messageId: messageId,
            ),
        ],
      );
    });
  }
}

enum _Kind { title, subtitle, paragraph, bullet, numbered }

class _Block {
  const _Block({
    required this.kind,
    required this.raw,
    this.indent = 0,
    this.number,
  });

  final _Kind kind;
  final String raw;
  final int indent;
  final int? number;
}

List<_Block> _parseBlocks(String text) {
  final lines = text.replaceAll('\r\n', '\n').split('\n');
  final out = <_Block>[];
  for (final rawLine in lines) {
    final line = rawLine.trimRight();
    if (line.trim().isEmpty) continue;

    final heading = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(line.trim());
    if (heading != null) {
      out.add(
        _Block(
          kind: heading.group(1)!.length <= 2 ? _Kind.title : _Kind.subtitle,
          raw: heading.group(2)!.trim(),
        ),
      );
      continue;
    }

    final numbered = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(line.trim());
    if (numbered != null) {
      out.add(
        _Block(
          kind: _Kind.numbered,
          raw: numbered.group(2)!.trim(),
          number: int.tryParse(numbered.group(1)!),
        ),
      );
      continue;
    }

    final bullet = RegExp(r'^(\s*)(?:[-•]|\*)\s+(.+)$').firstMatch(line);
    if (bullet != null) {
      final indent = (bullet.group(1)!.replaceAll('\t', '  ').length / 2)
          .floor()
          .clamp(0, 2);
      out.add(
        _Block(
          kind: _Kind.bullet,
          raw: bullet.group(2)!.trim(),
          indent: indent,
        ),
      );
      continue;
    }

    final onlyBold = RegExp(r'^\*\*(.+?)\*\*:?\s*$').firstMatch(line.trim());
    if (onlyBold != null) {
      out.add(_Block(kind: _Kind.title, raw: onlyBold.group(1)!.trim()));
      continue;
    }

    out.add(_Block(kind: _Kind.paragraph, raw: line.trim()));
  }
  return out;
}

class _BlockView extends StatelessWidget {
  const _BlockView({
    required this.block,
    required this.isFirst,
    required this.messageId,
  });

  final _Block block;
  final bool isFirst;
  final String messageId;

  @override
  Widget build(BuildContext context) {
    final top = isFirst
        ? 0.0
        : switch (block.kind) {
            _Kind.title => 14.h,
            _Kind.subtitle => 10.h,
            _Kind.bullet || _Kind.numbered => 8.h,
            _Kind.paragraph => 8.h,
          };

    return Padding(
      padding: EdgeInsets.only(top: top),
      child: switch (block.kind) {
        _Kind.title => _RichLine(
            raw: block.raw,
            messageId: messageId,
            size: 17,
            weight: FontWeight.w700,
            height: 1.3,
          ),
        _Kind.subtitle => _RichLine(
            raw: block.raw,
            messageId: messageId,
            size: 15.5,
            weight: FontWeight.w700,
            height: 1.35,
          ),
        _Kind.paragraph => _RichLine(
            raw: block.raw,
            messageId: messageId,
            size: 14.5,
            weight: FontWeight.w400,
            height: 1.45,
          ),
        _Kind.bullet => _MarkedLine(
            marker: '•',
            raw: block.raw,
            indent: block.indent,
            messageId: messageId,
          ),
        _Kind.numbered => _MarkedLine(
            marker: '${block.number ?? 1}.',
            raw: block.raw,
            indent: 0,
            messageId: messageId,
            markerWidth: 22.w,
          ),
      },
    );
  }
}

class _MarkedLine extends StatelessWidget {
  const _MarkedLine({
    required this.marker,
    required this.raw,
    required this.indent,
    required this.messageId,
    this.markerWidth,
  });

  final String marker;
  final String raw;
  final int indent;
  final String messageId;
  final double? markerWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent * 14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: markerWidth ?? 16.w,
            child: Text(
              marker,
              style: TextStyle(
                fontSize: 14.5.sp,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: _LabeledOrRich(raw: raw, messageId: messageId),
          ),
        ],
      ),
    );
  }
}

class _LabeledOrRich extends StatelessWidget {
  const _LabeledOrRich({required this.raw, required this.messageId});

  final String raw;
  final String messageId;

  @override
  Widget build(BuildContext context) {
    final labeled = RegExp(r'^\*\*(.+?)\*\*:?\s*(.*)$', dotAll: true).firstMatch(raw);
    if (labeled != null) {
      final label = labeled.group(1)!.trim();
      final rest = labeled.group(2)!.trim();
      return Text.rich(
        TextSpan(
          children: [
            ..._inlineSpans(
              label,
              messageId: messageId,
              size: 15.5,
              weight: FontWeight.w700,
              height: 1.4,
            ),
            if (rest.isNotEmpty)
              ..._inlineSpans(
                rest.startsWith(':') ? rest : ' $rest',
                messageId: messageId,
                size: 14.5,
                weight: FontWeight.w400,
                height: 1.45,
              ),
          ],
        ),
      );
    }

    return _RichLine(
      raw: raw,
      messageId: messageId,
      size: 14.5,
      weight: FontWeight.w400,
      height: 1.45,
    );
  }
}

class _RichLine extends StatelessWidget {
  const _RichLine({
    required this.raw,
    required this.messageId,
    required this.size,
    required this.weight,
    required this.height,
  });

  final String raw;
  final String messageId;
  final double size;
  final FontWeight weight;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: _inlineSpans(
          raw,
          messageId: messageId,
          size: size,
          weight: weight,
          height: height,
        ),
      ),
    );
  }
}

List<InlineSpan> _inlineSpans(
  String raw, {
  required String messageId,
  required double size,
  required FontWeight weight,
  required double height,
}) {
  final base = TextStyle(
    fontSize: size.sp,
    fontWeight: weight,
    height: height,
    color: AppColors.primaryText,
  );
  final spans = <InlineSpan>[];
  final pattern = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');
  var index = 0;
  for (final match in pattern.allMatches(raw)) {
    if (match.start > index) {
      spans.addAll(
        _findSpans(raw.substring(index, match.start), base, messageId),
      );
    }
    if (match.group(1) != null) {
      spans.addAll(
        _findSpans(
          match.group(1)!,
          base.copyWith(fontWeight: FontWeight.w700),
          messageId,
        ),
      );
    } else {
      spans.addAll(
        _findSpans(
          match.group(2)!,
          base.copyWith(fontStyle: FontStyle.italic),
          messageId,
        ),
      );
    }
    index = match.end;
  }
  if (index < raw.length) {
    spans.addAll(_findSpans(raw.substring(index), base, messageId));
  }
  if (spans.isEmpty) {
    spans.addAll(_findSpans(raw, base, messageId));
  }
  return spans;
}

List<InlineSpan> _findSpans(String text, TextStyle style, String messageId) {
  final chat = Get.find<ChatbotController>();
  final query = chat.findQuery.value.trim();
  if (query.isEmpty || text.isEmpty) {
    return [TextSpan(text: text, style: style)];
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
      spans.add(TextSpan(text: text.substring(from), style: style));
      break;
    }
    if (at > from) {
      spans.add(TextSpan(text: text.substring(from, at), style: style));
    }
    final end = at + needle.length;
    final isActive = active != null &&
        active.messageId == messageId &&
        active.start == at;
    spans.add(
      TextSpan(
        text: text.substring(at, end),
        style: style.copyWith(
          backgroundColor: isActive
              ? AppColors.lightGreen.withValues(alpha: 0.90)
              : AppColors.lightGreen.withValues(alpha: 0.38),
          fontWeight: isActive ? FontWeight.w700 : style.fontWeight,
        ),
      ),
    );
    from = end;
  }
  return spans;
}
