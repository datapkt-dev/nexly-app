import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nexly/components/widgets/keyboard_dismiss.dart';
import '../../../../app/config/app_config.dart';
import '../../../../unit/auth_service.dart';
import '../../di/providers.dart';
import 'comment_board/comment_input_bar.dart';
import 'comment_board/comment_list.dart';
import 'comment_board/reply_indicator.dart';

class CommentBoard extends ConsumerStatefulWidget {
  final int id;
  const CommentBoard({super.key, required this.id});

  @override
  ConsumerState<CommentBoard> createState() => _CommentBoardState();
}

class _CommentBoardState extends ConsumerState<CommentBoard> {
  final ScrollController _scrollController = ScrollController();
  List comments = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true; // API 還有沒有下一頁

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

    setState(() {
      page += 1;
      comments.addAll(newItems);
      isLoading = false;

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

  Future<void> postLikeComment(int id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/comments/$id/like/toggle');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // final body = jsonEncode(temp);

    try {
      final response = await http.post(url, headers: headers,);
      final responseData = jsonDecode(response.body);

      // return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      // return {'error': e.toString()};
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
      loadMore(id);
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
          loadMore(id);
        }
      });
    }
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
                  child: Column(
                    children: [
                      Expanded(
                        child: CommentList(
                          comments: comments,
                          onLike: (comment) {
                            setState(() {
                              postLikeComment(comment['id']);
                              comment['is_liked'] = !comment['is_liked'];
                            });
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
                            final overlayState =
                            Navigator.of(context, rootNavigator: true).overlay!;
                            final overlayBox =
                            overlayState.context.findRenderObject() as RenderBox;

                            return await showMenu<String>(
                              context: overlayState.context,
                              position: RelativeRect.fromLTRB(
                                globalPos.dx,
                                globalPos.dy + 8,
                                overlayBox.size.width - globalPos.dx,
                                overlayBox.size.height - globalPos.dy,
                              ),
                              items: const [
                                PopupMenuItem(value: 'reply', child: Text('回覆')),
                                PopupMenuItem(value: 'edit', child: Text('編輯')),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('刪除', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      if (!hasMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('沒有更多留言了'),
                        ),
                    ],
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
                    final now = DateTime.now();
                    final formattedNow =
                        '${now.year.toString().padLeft(4, '0')}-'
                        '${now.month.toString().padLeft(2, '0')}-'
                        '${now.day.toString().padLeft(2, '0')} '
                        '${now.hour.toString().padLeft(2, '0')}:'
                        '${now.minute.toString().padLeft(2, '0')}';
                    setState(() {
                      if (_replyMode) {
                        futureData = postReplyComment(id, replyTemp!['id'], _controller.text);
                        futureData.then((result) {
                          print(result);
                        });
                      } else {
                        futureData = postComment(id, _controller.text);
                        futureData.then((result) {
                          print(result);
                          if (result['message'] == 'Comment created successfully') {
                            if (comments.isEmpty) {
                              hasMore = true;   // 重新允許分頁
                              page = 2;         // page=1 已經是目前這一批
                            }

                            comments.insert(
                              0,
                              {
                                'id' : 0,
                                'content' : _controller.text,
                                'user_id' : user?['id'],
                                'user_name' : user?['name'],
                                'user_avatar_url' : user?['avatar_url'],
                                'like_count' : 0,
                                'is_liked' : false,
                                'time_added' : formattedNow,
                              },
                            );
                            _controller.text = '';
                            _focusNode.unfocus();
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
