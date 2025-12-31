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
      ) onLongPressMenu;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onLike,
    this.onReply,
    required this.onLongPressMenu,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = DateTime
        .parse(comment['time_added'])
        .toLocal()
        .toString()
        .substring(0, 16)
        .replaceAll('T', ' ');

    return GestureDetector(
      onLongPressStart: (details) async {
        await onLongPressMenu(context, details.globalPosition);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentAvatar(url: comment['user_avatar_url']),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommentHeader(
                  name: comment['user_name'],
                  isLiked: comment['is_liked'],
                  onLike: onLike,
                ),
                const SizedBox(height: 4),
                Text(comment['content']),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatted,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    // if (onReply != null) ...[
                    //   const SizedBox(width: 10),
                    //   GestureDetector(
                    //     onTap: onReply,
                    //     child: const Text(
                    //       '回覆',
                    //       style: TextStyle(fontSize: 12, color: Colors.grey),
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}