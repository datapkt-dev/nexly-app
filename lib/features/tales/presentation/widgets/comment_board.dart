import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nexly/components/widgets/keyboard_dismiss.dart';
import '../../../../app/config/app_config.dart';
import '../../../../unit/auth_service.dart';

class CommentBoard extends StatefulWidget {
  final int id;
  const CommentBoard({super.key, required this.id});

  @override
  State<CommentBoard> createState() => _CommentBoardState();
}

class _CommentBoardState extends State<CommentBoard> {
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
      print(responseData);

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

    final url = Uri.parse('$baseUrl/tales/comments/$id/like');
    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // final body = jsonEncode(temp);

    try {
      final response = await http.post(url, headers: headers,);
      final responseData = jsonDecode(response.body);
      print(responseData);

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
            _scrollController.position.maxScrollExtent - 200) {
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
                        // 用於顯示第二層留言
                        // if (true) ...[
                        //   SizedBox(height: 20,),
                        //   Row(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       SizedBox(width: 48,),
                        //       Container(
                        //         width: 40,
                        //         height: 40,
                        //         decoration: ShapeDecoration(
                        //           image: DecorationImage(
                        //             image: AssetImage('assets/images/ChatGPTphoto.png'),
                        //             fit: BoxFit.cover,
                        //           ),
                        //           shape: OvalBorder(
                        //             side: BorderSide(
                        //               width: 2,
                        //               color: const Color(0xFFE7E7E7),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //       const SizedBox(width: 8),
                        //       // 右側文字塊
                        //       Expanded(
                        //         child: Column(
                        //           mainAxisAlignment: MainAxisAlignment.center,
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Row(
                        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(
                        //                   'Chris1122',
                        //                   style: TextStyle(
                        //                     color: const Color(0xFF333333),
                        //                     fontSize: 14,
                        //                     fontFamily: 'PingFang TC',
                        //                     fontWeight: FontWeight.w500,
                        //                   ),
                        //                 ),
                        //                 GestureDetector(
                        //                   child: Icon(
                        //                     Icons.favorite,
                        //                     size: 20,
                        //                     // color: like[1] ? Colors.red : Color(0xFFD9D9D9),
                        //                   ),
                        //                   onTap: () {
                        //                     setState(() {
                        //                       // like[1] = !like[1];
                        //                     });
                        //                   },
                        //                 ),
                        //               ],
                        //             ),
                        //             SizedBox(height: 4),
                        //             Text(
                        //               '看起來很讚欸',
                        //               style: TextStyle(
                        //                 color: const Color(0xFF333333),
                        //                 fontSize: 14,
                        //                 fontFamily: 'PingFang TC',
                        //                 fontWeight: FontWeight.w400,
                        //               ),
                        //             ),
                        //             SizedBox(height: 4),
                        //             Text(
                        //               '今天 12:00',
                        //               style: TextStyle(
                        //                 color: Color(0xFF888888),
                        //                 fontSize: 12,
                        //                 fontFamily: 'PingFang TC',
                        //                 fontWeight: FontWeight.w400,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ],
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
                          if (result['message'] == 'Comment created successfully') {
                            comments.insert(
                              0,
                              {
                                'id' : 0,
                                'content' : _controller.text,
                                'user' : {
                                  'id' : user?['id'],
                                  'name' : user?['name'],
                                  'user_avatar_url' : user?['avatar_url'],
                                  'background_url' : '',
                                },
                                'like_count' : 0,
                                'is_liked' : false,
                                'time_added' : formattedNow,
                              },
                            );
                            _controller.text = '';
                            _focusNode.unfocus();
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
        return CommentItem(
          comment: comment,
          onLike: () => onLike(comment),
          onReply: () => onReply(comment),
          onLongPressMenu: onLongPressMenu,
        );
      },
    );
  }
}

class CommentItem extends StatelessWidget {
  final Map comment;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final Future<String?> Function(
      BuildContext context,
      Offset globalPosition,
      ) onLongPressMenu;

  const CommentItem({
    super.key,
    required this.comment,
    required this.onLike,
    required this.onReply,
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
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onReply,
                      child: const Text(
                        '回覆',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
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

class CommentAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const CommentAvatar({
    super.key,
    required this.url,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: const Color(0xFFE7E7E7),
        image: hasUrl
            ? DecorationImage(
          image: NetworkImage(url!),
          fit: BoxFit.cover,
        )
            : null,
        shape: OvalBorder(
          side: BorderSide(
            width: 2,
            color: const Color(0xFFE7E7E7),
          ),
        ),
      ),
    );
  }
}

class CommentHeader extends StatelessWidget {
  final String name;
  final bool isLiked;
  final VoidCallback onLike;

  const CommentHeader({
    super.key,
    required this.name,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onLike,
          child: Icon(
            Icons.favorite,
            size: 20,
            color: isLiked ? Colors.red : const Color(0xFFD9D9D9),
          ),
        ),
      ],
    );
  }
}

class ReplyIndicator extends StatelessWidget {
  final String name;
  final VoidCallback onCancel;

  const ReplyIndicator({
    super.key,
    required this.name,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '正在回覆 $name',
          style: const TextStyle(color: Color(0xFF898989)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onCancel,
          child: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showSend;
  final VoidCallback onSend;

  const CommentInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.showSend,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFECF0F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: '新增留言',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (showSend) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF2C538A),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset('assets/icons/leave_comment.svg'),
            ),
          ),
        ],
      ],
    );
  }
}
