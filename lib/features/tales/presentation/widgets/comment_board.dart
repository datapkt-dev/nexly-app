import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexly/components/widgets/keyboard_dismiss.dart';
import '../../../../app/config/app_config.dart';
import '../../../../unit/auth_service.dart';
import '../../di/tales_providers.dart';
import 'comment_board/comment_input_bar.dart';
import 'comment_board/comment_list.dart';
import 'comment_board/reply_indicator.dart';

class CommentBoard extends ConsumerStatefulWidget {
  final int id;
  final int? highlightCommentId;
  final VoidCallback? onCommentAdded;
  const CommentBoard({super.key, required this.id, this.highlightCommentId, this.onCommentAdded});

  @override
  ConsumerState<CommentBoard> createState() => _CommentBoardState();
}

class _CommentBoardState extends ConsumerState<CommentBoard> {
  final ScrollController _scrollController = ScrollController();
  List comments = [];
  int page = 1;
  bool isLoading = false;
  bool _isFirstLoad = true;
  bool hasMore = true; // API 還有沒有下一頁
  int? _highlightId; // ✅ 要高亮的留言 ID

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;
  bool _replyMode = false;
  Map<String, dynamic>? replyTemp;
  // List<bool> like = [false, false];

  Future<Map<String, dynamic>> futureData = Future.value({});
  Map<String, dynamic>? user;
  late int id;
  // List? comments;

  Future<Map<String, dynamic>> getCommentsList(int postID, int page) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;
    final url = Uri.parse('$baseUrl/tales/$postID/comments?page=$page&page_size=10');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 假設 API 是 Bearer Token
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<void> loadMore(int postId) async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    final result = await getCommentsList(postId, page);

    final List newItems =
        (result['data']?['comments'] as List?) ?? [];

    // ✅ 預載所有頭像到記憶體快取，完成後再一次顯示
    if (newItems.isNotEmpty && mounted) {
      await Future.wait(
        newItems
            .where((c) => c['user_avatar_url'] != null && c['user_avatar_url'].toString().isNotEmpty)
            .map((c) {
              try {
                return precacheImage(CachedNetworkImageProvider(c['user_avatar_url']), context);
              } catch (_) {
                return Future.value();
              }
            })
            .toList(),
      );
    }

    if (!mounted) return;

    setState(() {
      page += 1;
      comments.addAll(newItems);
      isLoading = false;
      _isFirstLoad = false;

      // ⚠️ 重點：小於 page_size 就代表沒下一頁
      if (newItems.length < 10) {
        hasMore = false;
      }
    });
  }

  Future<void> loadUser() async {
    final AuthService authStorage = AuthService();
    user = await authStorage.getProfile();
  }

  Future<bool> postLikeComment(int id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/comments/$id/like/toggle');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(url, headers: headers,);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('postLikeComment 失敗：statusCode=${response.statusCode}, body=${response.body}');
        return false;
      }
    } catch (e) {
      print('postLikeComment 請求錯誤：$e');
      return false;
    }
  }

  Future<Map<String, dynamic>> postComment(int postId, String comment) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/$postId/comments');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "content": comment
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> postReplyComment(int postId, int replyId, String comment) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/$postId/comments');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "content": comment,
      "parent_id": replyId
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  void _initComments() {
    page = 1;
    comments.clear();
    hasMore = true;
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();

    _highlightId = widget.highlightCommentId;

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (!_isFocused) _replyMode = false;
      });
    });

    loadUser();

    if (widget.id > 0) {
      id = widget.id;
      _initComments();
      _loadAndScrollToTarget();
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
          loadMore(id);
        }
      });
    }
  }

  /// 載入留言並自動捲動到目標留言
  Future<void> _loadAndScrollToTarget() async {
    await loadMore(id);
    if (_highlightId == null) return;

    // 持續載入直到找到目標留言或沒有更多
    while (mounted && hasMore && !_hasComment(_highlightId!)) {
      await loadMore(id);
    }

    if (!mounted || !_hasComment(_highlightId!)) return;

    // 找到目標留言的 index，等一幀後捲動過去
    final targetIndex = comments.indexWhere((c) => c['id'] == _highlightId);
    if (targetIndex < 0) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      // 估算每則留言高度約 80，捲動到目標位置
      final targetOffset = targetIndex * 80.0;
      _scrollController.animateTo(
        targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      // 3 秒後自動取消高亮
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _highlightId = null;
          });
        }
      });
    });
  }

  bool _hasComment(int commentId) {
    return comments.any((c) => c['id'] == commentId);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kb = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: kb),
      child: FractionallySizedBox(
        heightFactor: 0.7,
        child: KeyboardDismissOnTap(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16,),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // 小手把
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDADADA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                // 標題列 + 關閉
                Center(
                  child: Text(
                    '留言',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 18,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 8,),
                // 可滾動內容
                Expanded(
                  child: CommentList(
                    comments: comments,
                    scrollController: _scrollController,
                    isLoading: isLoading,
                    hasMore: hasMore,
                    isFirstLoad: _isFirstLoad,
                    highlightCommentId: _highlightId,
                    onLike: (comment) async {
                      HapticFeedback.lightImpact();
                      final prevLiked = comment['is_liked'];
                      setState(() {
                        comment['is_liked'] = !comment['is_liked'];
                      });
                      final success = await postLikeComment(comment['id']);
                      if (!success && mounted) {
                        setState(() {
                          comment['is_liked'] = prevLiked;
                        });
                      }
                    },
                    onReply: (comment) {
                      setState(() {
                        _replyMode = true;
                        replyTemp = Map<String, dynamic>.from(comment);;
                        Future.delayed(const Duration(milliseconds: 50), () {
                          FocusScope.of(context).requestFocus(_focusNode);
                        });
                      });
                    },
                    onLongPressMenu: (context, globalPos) async {
                    },
                  ),
                ),
                Divider(),
                if (_replyMode) ...[
                  ReplyIndicator(
                    name: replyTemp!['user_name'],
                    onCancel: () {
                      setState(() {
                        replyTemp = null;
                        _replyMode = false;
                        _focusNode.unfocus();
                      });
                    },
                  ),
                ],
                CommentInputBar(
                  controller: _controller,
                  focusNode: _focusNode,
                  showSend: _isFocused,
                  onSend: () {
                    final text = _controller.text.trim();
                    if (text.isEmpty) return;

                    if (_replyMode) {
                      futureData = postReplyComment(id, replyTemp!['id'], text);
                      futureData.then((result) {
                        print(result);
                      });
                      _controller.clear();
                      _focusNode.unfocus();
                      return;
                    }

                    // ✅ 立即顯示留言，time_added 先設 null → 畫面顯示「發佈中......」
                    final pendingComment = {
                      'id': 0,
                      'content': text,
                      'user_id': user?['id'],
                      'user_name': user?['name'],
                      'user_avatar_url': user?['avatar_url'],
                      'like_count': 0,
                      'is_liked': false,
                      'time_added': null,
                    };

                    setState(() {
                      if (comments.isEmpty) {
                        hasMore = true;
                        page = 2;
                      }
                      comments.insert(0, pendingComment);
                      _controller.clear();
                      _focusNode.unfocus();
                    });

                    // ✅ 背景打 API
                    postComment(id, text).then((result) {
                      if (!mounted) return;
                      if (result['message'] == 'Comment created successfully') {
                        final data = result['data'];
                        setState(() {
                          // 用 API 回傳的真實時間替換「發佈中......」
                          pendingComment['time_added'] = data?['time_added'];
                          if (data?['id'] != null) {
                            pendingComment['id'] = data['id'];
                          }
                        });
                        // ✅ 輕微震動表示發佈成功
                        HapticFeedback.lightImpact();
                        widget.onCommentAdded?.call();
                        ref.read(talesFeedProvider.notifier).state = [
                          for (final tale in ref.read(talesFeedProvider))
                            if (tale['id'] == id)
                              {
                                ...tale,
                                'comment_count': (tale['comment_count'] as int) + 1,
                              }
                            else
                              tale,
                        ];
                      }
                    });
                  },
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
