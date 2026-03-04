import 'package:flutter/material.dart';

import 'comment_item.dart';
import 'comment_shimmer.dart';

class CommentList extends StatelessWidget {
  final List comments;
  final ScrollController? scrollController;
  final bool isLoading;
  final bool hasMore;
  final bool isFirstLoad;
  final int? highlightCommentId;
  final void Function(Map comment) onLike;
  final void Function(Map comment) onReply;
  final Future<String?> Function(
      BuildContext context,
      Offset globalPosition,
      ) onLongPressMenu;

  const CommentList({
    super.key,
    required this.comments,
    this.scrollController,
    this.isLoading = false,
    this.hasMore = true,
    this.isFirstLoad = false,
    this.highlightCommentId,
    required this.onLike,
    required this.onReply,
    required this.onLongPressMenu,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 首次載入中 → 顯示 shimmer
    if (isFirstLoad && comments.isEmpty) {
      return const CommentShimmer();
    }

    // ✅ 沒有留言且已載完 → 顯示空狀態
    if (comments.isEmpty && !isLoading && !hasMore) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: Color(0xFFD9D9D9)),
            const SizedBox(height: 12),
            Text(
              '尚無留言',
              style: TextStyle(
                color: Color(0xFF838383),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '快來留下第一則留言吧！',
              style: TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 14,
                fontFamily: 'PingFang TC',
              ),
            ),
          ],
        ),
      );
    }

    // ✅ 只有在超過一頁（留言數 >= 10）才顯示底部「沒有更多留言了」
    final showEndText = !hasMore && comments.length >= 10;
    final extraCount = (isLoading || showEndText) ? 1 : 0;
    final totalCount = comments.length + extraCount;

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: totalCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        // 底部 shimmer / 沒有更多
        if (index >= comments.length) {
          if (isLoading) {
            return const CommentShimmer();
          }
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: Text('沒有更多留言了', style: TextStyle(color: Color(0xFF838383)))),
          );
        }

        final comment = comments[index];
        final isHighlighted = highlightCommentId != null && comment['id'] == highlightCommentId;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFFF46C3F).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
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
                                onReply: null,
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
          ),
        );
      },
    );
  }
}