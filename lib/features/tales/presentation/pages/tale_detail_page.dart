import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexly/features/tales/presentation/widgets/comment_board.dart';
import 'package:nexly/features/tales/presentation/widgets/like_list.dart';
import 'package:nexly/features/tales/presentation/widgets/report.dart';
import '../../../../app/config/app_config.dart';
import '../../../../modules/account_setting/controller/accountSetting_controller.dart';
import '../../../../modules/profile/profile.dart';
import '../../../../modules/providers.dart';
import '../../../../unit/auth_service.dart';
import '../widgets/TaleDetailShimmer.dart';
import 'edit_tale_page.dart';

class Post extends ConsumerStatefulWidget {
  final int id;
  final Map<String, dynamic>? previewData;
  final String? heroTag;
  final int? openCommentId;
  const Post({super.key, this.id = 0, this.previewData, this.heroTag, this.openCommentId});

  @override
  ConsumerState<Post> createState() => _PostState();
}

enum _PostMenu {edit, copyToCollab, delete, report,}

class _PostState extends ConsumerState<Post> {
  late int id;
  bool liked = false;
  bool self = false;
  Map<String, dynamic> postContent = {};

  // ✅ local state — 不再動 talesFeedProvider
  bool _isLiked = false;
  bool _isFavorited = false;
  int _likeCount = 0;
  int _commentCount = 0;

  // ✅ 兩階段載入
  bool _detailLoaded = false;
  Map<String, dynamic>? _fullContent;

  Future<Map<String, dynamic>> getTaleContent(int id) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;
    final url = Uri.parse('$baseUrl/projects/1/tales/$id');
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

  Future<bool> postLikeTale(int id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/$id/like/toggle');

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
        print('postLikeTale 失敗：statusCode=${response.statusCode}, body=${response.body}');
        return false;
      }
    } catch (e) {
      print('postLikeTale 請求錯誤：$e');
      return false;
    }
  }

  Future<void> postFavoriteTale(int id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/$id/favorite/toggle');

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

  Future<Map<String, dynamic>> deleteTale(int id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/projects/1/tales/$id');

    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // final body = jsonEncode(temp);

    try {
      final response = await http.delete(url, headers: headers,);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'error': e.toString()};
    }
  }

  @override
  void initState() {
    super.initState();

    id = widget.id;

    // ✅ Phase 1: 如果有 previewData，立即用它顯示 UI（零等待）
    if (widget.previewData != null) {
      final p = widget.previewData!;
      _isFavorited = p['is_favorited'] ?? false;
      _isLiked = p['is_liked'] ?? false;
      _likeCount = p['like_count'] ?? 0;
      _commentCount = p['comment_count'] ?? 0;

      final userData = ref.read(userProfileProvider);
      if (userData['id'] == p['user_id']) self = true;
    }

    // ✅ Phase 2: 背景取得完整資料，到了再 merge（使用者不會看到 shimmer）
    getTaleContent(id).then((result) {
      if (!mounted || result['data'] == null) return;
      final Map<String, dynamic> content = Map<String, dynamic>.from(result['data']);

      final userData = ref.read(userProfileProvider);
      if (userData['id'] == content['user_id']) self = true;

      setState(() {
        _fullContent = content;
        postContent = content;
        _detailLoaded = true;
        _isLiked = content['is_liked'] ?? _isLiked;
        _isFavorited = content['is_favorited'] ?? _isFavorited;
        _likeCount = content['like_count'] ?? _likeCount;
        _commentCount = content['comment_count'] ?? _commentCount;
      });

      // ✅ 從通知進來時，自動展開留言板並定位到該留言
      if (widget.openCommentId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => CommentBoard(
              id: id,
              highlightCommentId: widget.openCommentId,
              onCommentAdded: () {
                setState(() {
                  _commentCount += 1;
                });
              },
            ),
          );
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            // ✅ 一般返回不要帶 'refresh'，避免動態牆重載造成圖片閃爍
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '貼文',
          style: TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!self) ...[
            // IconButton(
            //   onPressed: () {
            //     ShareBottomSheet.show(context);
            //   },
            //   icon: const Icon(Icons.open_in_new),
            // ),
          ],
          PopupMenuButton<_PostMenu>(
            icon: const Icon(Icons.more_vert),
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFEDEDED)),
            ),
            color: Colors.white,
            elevation: 8,
            constraints: const BoxConstraints(minWidth: 180),
            onSelected: (v) async {
              switch (v) {
                case _PostMenu.edit:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditTalePage(postContent: postContent,)),
                ).then((result) {
                  if (result == 'refresh') {
                    getTaleContent(id).then((res) {
                      if (!mounted || res['data'] == null) return;
                      final c = Map<String, dynamic>.from(res['data']);
                      setState(() {
                        _fullContent = c;
                        postContent = c;
                        _isLiked = c['is_liked'] ?? _isLiked;
                        _isFavorited = c['is_favorited'] ?? _isFavorited;
                        _likeCount = c['like_count'] ?? _likeCount;
                        _commentCount = c['comment_count'] ?? _commentCount;
                      });
                    });
                  }
                });
                  break;
                case _PostMenu.copyToCollab:
                  break;
                case _PostMenu.delete:
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('刪除貼文'),
                      content: const Text('確定要刪除此貼文嗎？'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                        TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('確定')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    deleteTale(id).then((result) {
                      print(result);
                      if (result['message'] == 'Tale deleted successfully') {
                        Navigator.pop(context, 'refresh');
                      }
                    });
                  }
                  break;
                case _PostMenu.report:
                  final result = await ReportBottomSheet.showAndSubmit(
                    context,
                    targetId: id,
                    targetType: ReportTarget.tales,
                    onSubmit: (report) async {
                      final controller = AccountSettingController();
                      return await controller.postReport(
                        report.targetType.name,
                        report.targetId,
                        report.reason.name,
                        // note: report.note,
                      );
                    },
                  );
                  if (result?['message'] == 'Report submitted successfully') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已送出檢舉')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${result?['message']}')),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              if (self) ...[
                const PopupMenuItem(
                  value: _PostMenu.edit,
                  child: Text('編輯貼文'),
                ),
                const PopupMenuItem(
                  value: _PostMenu.copyToCollab,
                  child: Text('複製至協作'),
                ),
                const PopupMenuItem(
                  value: _PostMenu.delete,
                  child: Text(
                    '刪除貼文',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ] else
                const PopupMenuItem(
                  value: _PostMenu.report,
                  child: Text('檢舉貼文'),
                ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final preview = widget.previewData;
    final hasPreview = preview != null;

    // 沒有 previewData 且 API 還沒回來 → 顯示 shimmer
    if (!hasPreview && !_detailLoaded) {
      return const TaleDetailShimmer();
    }

    // 決定顯示的資料來源：優先用 full，fallback 用 preview
    final content = _fullContent ?? preview ?? {};
    final imageUrl = content['image_url'] ?? '';
    final title = content['title'] ?? '';
    final contentText = content['content'] ?? '';
    final user = content['user'];
    final userId = content['user_id'];
    final timeAdded = content['time_added'];

    final int commentCount = _commentCount;
    final int likeCount = _likeCount;
    final bool isLiked = _isLiked;
    final bool isFavorited = _isFavorited;

    postContent = _fullContent ?? {};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Hero 圖片 =====
          Hero(
            tag: widget.heroTag ?? 'tale-image-$id',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                image: CachedNetworkImageProvider(imageUrl),
                width: double.infinity,
                height: 513,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) => Container(
                  height: 513,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E7E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // ===== 使用者列 =====
                Row(
                  children: [
                    GestureDetector(
                      child: Row(
                        children: [
                          if (user != null) ...[
                            ClipOval(
                              child: Image(
                                image: CachedNetworkImageProvider(
                                  user['avatar_url'] ?? '',
                                ),
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
                                errorBuilder: (_, __, ___) => const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFFE7E7E7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user['name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ] else ...[
                            // shimmer 佔位（API 還沒回來時）
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFE7E7E7),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7E7E7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: userId != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Profile(userId: userId),
                                ),
                              );
                            }
                          : null,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.bookmark,
                        color: isFavorited
                            ? const Color(0xFFD63C95)
                            : const Color(0xFFD9D9D9),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        postFavoriteTale(id);
                        final willFavorite = !_isFavorited;
                        setState(() {
                          _isFavorited = willFavorite;
                        });
                        if (willFavorite) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('已收藏', textAlign: TextAlign.center),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ===== Like / Comment =====
                Row(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.favorite,
                        color: isLiked
                            ? const Color(0xFFED4D4D)
                            : const Color(0xFFD9D9D9),
                      ),
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        // 先樂觀更新 UI
                        final prevLiked = _isLiked;
                        final prevCount = _likeCount;
                        setState(() {
                          _likeCount = _isLiked ? _likeCount - 1 : _likeCount + 1;
                          _isLiked = !_isLiked;
                        });
                        // 打 API，失敗時回滾
                        final success = await postLikeTale(id);
                        if (!success && mounted) {
                          setState(() {
                            _isLiked = prevLiked;
                            _likeCount = prevCount;
                          });
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    if (likeCount > 0) ...[
                      GestureDetector(
                        child: Text('$likeCount'),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => LikeList(id: id),
                          );
                        },
                      ),
                    ],
                    const SizedBox(width: 10),
                    GestureDetector(
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble, color: Color(0xFFD9D9D9)),
                          const SizedBox(width: 4),
                          Text(commentCount > 0 ? '$commentCount' : ''),
                        ],
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => CommentBoard(
                            id: id,
                            onCommentAdded: () {
                              setState(() {
                                _commentCount += 1;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // ===== 標題 =====
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // ===== 內文（只有 API 回來後才有）=====
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: contentText.isNotEmpty
                      ? Text(contentText)
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 4),
                // ===== 時間 =====
                if (timeAdded != null)
                  Text(
                    DateTime.parse(timeAdded)
                        .toLocal()
                        .toString()
                        .substring(0, 16)
                        .replaceAll('T', ' '),
                    style: const TextStyle(
                      color: Color(0xFF838383),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
