import 'package:flutter/material.dart';

import 'comment_avatar.dart';
import 'comment_header.dart';

class CommentItem extends StatelessWidget {
  final Map comment;
  final VoidCallback onLike;
  final VoidCallback? onReply;
  final Future<String?> Function(
      BuildContext context,
      Offset globalPosition,
      Map comment,
      ) onLongPressMenu;
  final bool isReply;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onLike,
    this.onReply,
    required this.onLongPressMenu,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeAdded = comment['time_added'];
    final bool isPending = timeAdded == null;
    final formatted = isPending
        ? '發佈中......'
        : DateTime
            .parse(timeAdded)
            .toLocal()
            .toString()
            .substring(0, 16)
            .replaceAll('T', ' ');

    final int replyCount = (comment['reply_count'] ?? comment['replies_count'] ?? 0) as int;
    final double avatarSize = isReply ? 32 : 40;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) async {
        debugPrint('[CommentItem] long press id=${comment['id']} at ${details.globalPosition}');
        await onLongPressMenu(context, details.globalPosition, comment);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentAvatar(url: comment['user_avatar_url'], size: avatarSize),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommentHeader(name: comment['user_name'] ?? ''),
                const SizedBox(height: 4),
                _buildContent(comment['content'] ?? ''),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatted,
                      style: TextStyle(
                        color: const Color(0xFF898989),
                        fontSize: 12,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w400,
                        fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    if (onReply != null) ...[
                      const SizedBox(width: 10),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onReply,
                        child: Text(
                          replyCount > 0 ? '回覆$replyCount' : '回覆',
                          style: const TextStyle(
                            color: Color(0xFF898989),
                            fontSize: 12,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 把內文中的 `@xxx` 片段渲染為藍色
  Widget _buildContent(String content) {
    const baseStyle = TextStyle(
      color: Color(0xFF333333),
      fontSize: 14,
      fontFamily: 'PingFang TC',
      fontWeight: FontWeight.w400,
    );
    const mentionStyle = TextStyle(
      color: Color(0xFF3B5AF8),
      fontSize: 14,
      fontFamily: 'PingFang TC',
      fontWeight: FontWeight.w400,
    );

    if (content.isEmpty) return const SizedBox.shrink();

    // 比對 @ 後非空白字元（允許中英數、底線、點）
    final regex = RegExp(r'@[^\s@]+');
    final matches = regex.allMatches(content).toList();
    if (matches.isEmpty) {
      return Text(content, style: baseStyle);
    }

    final spans = <TextSpan>[];
    int cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: content.substring(cursor, m.start), style: baseStyle));
      }
      spans.add(TextSpan(text: content.substring(m.start, m.end), style: mentionStyle));
      cursor = m.end;
    }
    if (cursor < content.length) {
      spans.add(TextSpan(text: content.substring(cursor), style: baseStyle));
    }
    return Text.rich(TextSpan(children: spans));
  }
}