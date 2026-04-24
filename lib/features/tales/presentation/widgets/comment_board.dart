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
import 'comment_board/action_menu_card.dart';

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
  final List<int> _mentions = []; // 即將隨留言送出的 mention user ids
  bool _editMode = false;
  int? _editingCommentId;
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

    final List rawItems =
        (result['data']?['comments'] as List?) ?? [];

    // ✅ 若後端回傳是扁平的（含 parent_id），前端自動聚合成巢狀
    final List newItems = _nestReplies(rawItems);

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

  Future<Map<String, dynamic>> postReplyComment(
      int postId, int replyId, String comment,
      {List<int>? mentions}) async {
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
      "parent_id": replyId,
      if (mentions != null && mentions.isNotEmpty) "mentions": mentions,
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

  Future<bool> deleteComment(int commentId) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/comments/$commentId');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.delete(url, headers: headers);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('deleteComment 請求錯誤：$e');
      return false;
    }
  }

  Future<bool> editComment(int commentId, String content) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/comments/$commentId');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({'content': content});

    try {
      final response =
          await http.patch(url, headers: headers, body: body);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('editComment 請求錯誤：$e');
      return false;
    }
  }

  void _initComments() {
    page = 1;
    comments.clear();
    hasMore = true;
    isLoading = false;
  }

  /// 把扁平的 comments（含 parent_id）聚合成巢狀結構：
  /// 父留言多一個 'replies' 陣列、'has_replies' 旗標、'reply_count'。
  /// 若後端已經巢狀回傳就直接保留不破壞。
  List _nestReplies(List raw) {
    final List parents = [];
    final Map<int, List<Map>> childrenByParent = {};

    for (final c in raw) {
      final m = Map<String, dynamic>.from(c as Map);
      final pid = m['parent_id'];
      if (pid is int) {
        childrenByParent.putIfAbsent(pid, () => []).add(m);
      } else {
        parents.add(m);
      }
    }

    for (final p in parents) {
      final id = p['id'];
      final existingReplies = (p['replies'] is List)
          ? List<Map>.from(p['replies'] as List)
          : <Map>[];
      final fromFlat = childrenByParent[id] ?? [];
      final merged = [...existingReplies, ...fromFlat];
      if (merged.isNotEmpty) {
        p['replies'] = merged;
        p['has_replies'] = true;
        p['reply_count'] = merged.length;
      }
    }
    return parents;
  }

  @override
  void initState() {
    super.initState();

    _highlightId = widget.highlightCommentId;

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (!_isFocused) {
          _replyMode = false;
          _editMode = false;
          _editingCommentId = null;
        }
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

  /// 找出指定 id 的 comment（支援頂層與 replies 內）
  Map? _findCommentById(int commentId) {
    for (final c in comments) {
      if (c['id'] == commentId) return c as Map;
      final replies = c['replies'];
      if (replies is List) {
        for (final r in replies) {
          if (r['id'] == commentId) return r as Map;
        }
      }
    }
    return null;
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
                      final targetName = (comment['user_name'] ?? '').toString();
                      final targetUserId = comment['user_id'];
                      final prefix = targetName.isNotEmpty ? '@$targetName ' : '';
                      setState(() {
                        _replyMode = true;
                        replyTemp = Map<String, dynamic>.from(comment);
                        _mentions
                          ..clear();
                        if (targetUserId is int) _mentions.add(targetUserId);
                        _controller.text = prefix;
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: prefix.length),
                        );
                        Future.delayed(const Duration(milliseconds: 50), () {
                          FocusScope.of(context).requestFocus(_focusNode);
                        });
                      });
                    },
                    onLongPressMenu: (ctx, globalPos, targetComment) async {
                      HapticFeedback.selectionClick();
                      final myId = user?['id'];
                      // 型別寬鬆比較（避免 int vs num/String 造成永遠 false）
                      final isOwn = myId != null &&
                          targetComment['user_id'] != null &&
                          myId.toString() == targetComment['user_id'].toString();
                      final isReply = targetComment['parent_id'] != null;

                      debugPrint(
                          '[ActionMenu] myId=$myId targetUserId=${targetComment['user_id']} '
                          'isOwn=$isOwn isReply=$isReply');

                      return showActionMenuAt(ctx, globalPos, (pop) {
                        return [
                          // 回覆（只有主留言才能回覆；自己的也不用回覆自己）
                          if (!isReply && !isOwn)
                            ActionMenuItem(
                              title: '回覆',
                              textColor: const Color(0xFF333333),
                              onTap: () {
                                pop('reply');
                                final targetName =
                                    (targetComment['user_name'] ?? '').toString();
                                final targetUserId = targetComment['user_id'];
                                final prefix = targetName.isNotEmpty ? '@$targetName ' : '';
                                setState(() {
                                  _replyMode = true;
                                  _editMode = false;
                                  _editingCommentId = null;
                                  replyTemp = Map<String, dynamic>.from(targetComment);
                                  _mentions.clear();
                                  if (targetUserId is int) _mentions.add(targetUserId);
                                  _controller.text = prefix;
                                  _controller.selection = TextSelection.fromPosition(
                                    TextPosition(offset: prefix.length),
                                  );
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    FocusScope.of(context).requestFocus(_focusNode);
                                  });
                                });
                              },
                            ),
                          // 編輯（只有自己的留言才出現）
                          if (isOwn)
                            ActionMenuItem(
                              title: '編輯',
                              textColor: const Color(0xFF333333),
                              onTap: () {
                                pop('edit');
                                final commentId = targetComment['id'];
                                if (commentId is! int || commentId == 0) return;
                                final existing =
                                    (targetComment['content'] ?? '').toString();
                                setState(() {
                                  _editMode = true;
                                  _editingCommentId = commentId;
                                  _replyMode = false;
                                  replyTemp = null;
                                  _mentions.clear();
                                  _controller.text = existing;
                                  _controller.selection = TextSelection.fromPosition(
                                    TextPosition(offset: existing.length),
                                  );
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    FocusScope.of(context).requestFocus(_focusNode);
                                  });
                                });
                              },
                            ),
                          // 刪除（只有自己的留言才出現）
                          if (isOwn)
                            ActionMenuItem(
                              title: '刪除',
                              textColor: const Color(0xFFE9416C),
                              onTap: () async {
                                pop('delete');
                                final commentId = targetComment['id'];
                                if (commentId is! int || commentId == 0) return;

                                // 樂觀刪除
                                setState(() {
                                  if (isReply) {
                                    final parentId = targetComment['parent_id'];
                                    final idx = comments.indexWhere((c) => c['id'] == parentId);
                                    if (idx != -1) {
                                      final p = comments[idx] as Map;
                                      final replies = List.from((p['replies'] as List?) ?? []);
                                      replies.removeWhere((r) => r['id'] == commentId);
                                      p['replies'] = replies;
                                      p['has_replies'] = replies.isNotEmpty;
                                      p['reply_count'] = replies.length;
                                    }
                                  } else {
                                    comments.removeWhere((c) => c['id'] == commentId);
                                  }
                                });

                                final ok = await deleteComment(commentId);
                                if (!mounted) return;
                                if (!ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('刪除失敗，請稍後再試')),
                                  );
                                } else {
                                  HapticFeedback.lightImpact();
                                  ref.read(talesFeedProvider.notifier).state = [
                                    for (final tale in ref.read(talesFeedProvider))
                                      if (tale['id'] == id)
                                        {
                                          ...tale,
                                          'comment_count':
                                              ((tale['comment_count'] ?? 0) as int) - 1,
                                        }
                                      else
                                        tale,
                                  ];
                                }
                              },
                            ),
                        ];
                      });
                    },
                  ),
                ),
                Divider(),
                if (_replyMode) ...[
                  ReplyIndicator(
                    label: '正在回覆 ${replyTemp!['user_name']}',
                    onCancel: () {
                      setState(() {
                        replyTemp = null;
                        _replyMode = false;
                        _mentions.clear();
                        _controller.clear();
                        _focusNode.unfocus();
                      });
                    },
                  ),
                ],
                if (_editMode) ...[
                  ReplyIndicator(
                    label: '編輯中',
                    onCancel: () {
                      setState(() {
                        _editMode = false;
                        _editingCommentId = null;
                        _controller.clear();
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

                    // ✅ 編輯模式
                    if (_editMode && _editingCommentId != null) {
                      final editId = _editingCommentId!;
                      final original = _findCommentById(editId);

                      setState(() {
                        // 樂觀更新畫面
                        if (original != null) original['content'] = text;
                        _editMode = false;
                        _editingCommentId = null;
                        _controller.clear();
                        _focusNode.unfocus();
                      });

                      editComment(editId, text).then((ok) {
                        if (!mounted) return;
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('編輯失敗，請稍後再試')),
                          );
                        } else {
                          HapticFeedback.lightImpact();
                        }
                      });
                      return;
                    }

                    if (_replyMode) {
                      final parent = replyTemp!;
                      final parentId = parent['id'] as int;

                      // ✅ 樂觀更新：立即把新回覆塞進父留言的 replies
                      final pendingReply = <String, dynamic>{
                        'id': 0,
                        'content': text,
                        'parent_id': parentId,
                        'user_id': user?['id'],
                        'user_name': user?['name'],
                        'user_avatar_url': user?['avatar_url'],
                        'like_count': 0,
                        'is_liked': false,
                        'time_added': null,
                      };

                      setState(() {
                        final idx = comments.indexWhere((c) => c['id'] == parentId);
                        if (idx != -1) {
                          final parentComment = comments[idx] as Map;
                          final List replies = (parentComment['replies'] as List?) ?? [];
                          parentComment['replies'] = [...replies, pendingReply];
                          parentComment['has_replies'] = true;
                          parentComment['reply_count'] =
                              ((parentComment['reply_count'] ?? parentComment['replies_count'] ?? 0) as int) + 1;
                        }
                        _controller.clear();
                        _focusNode.unfocus();
                        _replyMode = false;
                        replyTemp = null;
                      });

                      // ✅ 背景打 API（帶 mentions）
                      final mentionsSnapshot = List<int>.from(_mentions);
                      _mentions.clear();
                      postReplyComment(id, parentId, text,
                              mentions: mentionsSnapshot)
                          .then((result) {
                        if (!mounted) return;
                        if (result['message'] == 'Comment created successfully') {
                          final data = result['data'];
                          setState(() {
                            pendingReply['time_added'] = data?['time_added'];
                            if (data?['id'] != null) {
                              pendingReply['id'] = data['id'];
                            }
                          });
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
