import 'package:flutter/material.dart';

import 'comment_item.dart';

class CommentList extends StatelessWidget {
  final List comments;
  final void Function(Map comment) onLike;
  final void Function(Map comment) onReply;
  final Future<String?> Function(
      BuildContext context,
      Offset globalPosition,
      ) onLongPressMenu;

  const CommentList({
    super.key,
    required this.comments,
    required this.onLike,
    required this.onReply,
    required this.onLongPressMenu,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Column(
          children: [
            CommentItem(
              comment: comment,
              onLike: () => onLike(comment),
              onReply: () => onReply(comment),
              onLongPressMenu: onLongPressMenu,
            ),
            if (comment['has_replies'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: List.generate(
                    comment['replies'].length,
                        (i) {
                      final reply = comment['replies'][i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 48),
                            Expanded(
                              child: CommentItem(
                                comment: reply,
                                onLike: () => onLike(reply),
                                onReply: null, // 🔒 reply 不提供回覆
                                onLongPressMenu: onLongPressMenu,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}