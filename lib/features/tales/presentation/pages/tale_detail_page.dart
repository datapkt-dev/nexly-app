import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexly/features/tales/presentation/widgets/comment_board.dart';
import 'package:nexly/features/tales/presentation/widgets/like_list.dart';
import 'package:nexly/features/tales/presentation/widgets/report.dart';
import 'package:nexly/modules/user/user.dart';

import '../../../../app/config/app_config.dart';
import '../../../../modules/index/widgets/share_bottom_sheet.dart';
import '../../../../modules/profile/profile.dart';
import '../../../../unit/auth_service.dart';
import '../../di/providers.dart';

class Post extends ConsumerStatefulWidget {
  final bool myself;
  final int id;
  const Post({super.key, this.myself = false, this.id = 0});

  @override
  ConsumerState<Post> createState() => _PostState();
}

enum _PostMenu {edit, copyToCollab, delete, report,}

class _PostState extends ConsumerState<Post> {
  Future<Map<String, dynamic>> futureData = Future.value({});

  int? id;
  bool liked = false;
  bool myself = false;

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

  DecorationImage? _buildDecorationImage(networkImage) {
    if (networkImage.isEmpty) return null;

    final uri = Uri.tryParse(networkImage);

    // ⭐ 關鍵：一定要檢查 scheme + host
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }

    return DecorationImage(
      image: NetworkImage(networkImage),
      fit: BoxFit.cover,
    );
  }

  Future<void> postLikeTale(int id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/tales/$id/like/toggle');

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

  @override
  void initState() {
    super.initState();

    myself = widget.myself;
    id = widget.id;

    if (!myself && id != null) {
      futureData = getTaleContent(id!).then((result) {
        final content = result['data'];

        // ✅ 等 build 結束後，再同步更新 Riverpod
        Future.microtask(() {
          final notifier = ref.read(talesFeedProvider.notifier);
          final current = ref.read(talesFeedProvider);

          notifier.state = [
            for (final tale in current)
              if (tale['id'] == id)
                <String, dynamic>{
                  ...tale as Map<String, dynamic>,
                  ...content as Map<String, dynamic>,
                }
              else
                tale,
          ];
        });

        return result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 先把 provider 的資料「安全轉型」
    final List<Map<String, dynamic>> feed = ref
        .watch(talesFeedProvider)
        .map<Map<String, dynamic>>(
          (e) => Map<String, dynamic>.from(e),
    )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
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
          if (!myself)
            IconButton(
              onPressed: () {
                ShareBottomSheet.show(context);
              },
              icon: const Icon(Icons.open_in_new),
            ),
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
                    // TODO delete api
                  }
                  break;
                case _PostMenu.report:
                  await ReportBottomSheet.show(
                    context,
                    targetId: 'post_123',
                    targetType: ReportTarget.post,
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              if (myself) ...[
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
      body: FutureBuilder(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('讀取文章錯誤'));
          }

          final Map<String, dynamic> content = Map<String, dynamic>.from(snapshot.data!['data']);

          final Map<String, dynamic> tale =
          feed.firstWhere(
                (e) => e['id'] == id,
            orElse: () => content,
          );

          final int commentCount = tale['comment_count'] ?? 0;
          final int likeCount = tale['like_count'] ?? 0;
          final bool isLiked = tale['is_liked'] ?? false;
          final bool isFavorited = tale['is_favorited'] ?? false;

          final formatted = DateTime.parse(content['time_added'])
              .toLocal()
              .toString()
              .substring(0, 16)
              .replaceAll('T', ' ');

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 513,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7E7E7),
                    borderRadius: BorderRadius.circular(20),
                    image: _buildDecorationImage(content['image_url'] ?? ''),
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
                                CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                  NetworkImage(content['user']['avatar_url'] ?? ''),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  content['user']['name'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => const User()),
                              // );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfilePage.other(userId: '123'),
                                ),
                              );
                            },
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
                              postFavoriteTale(id!);
                              ref.read(talesFeedProvider.notifier).state = [
                                for (final t in feed)
                                  if (t['id'] == id)
                                    {
                                      ...t,
                                      'is_favorited': !isFavorited,
                                    }
                                  else
                                    t,
                              ];
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ===== Like / Comment =====
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: isLiked
                                  ? const Color(0xFFED4D4D)
                                  : const Color(0xFFD9D9D9),
                            ),
                            onPressed: () {
                              postLikeTale(id!);
                              ref.read(talesFeedProvider.notifier).state = [
                                for (final t in feed)
                                  if (t['id'] == id)
                                    {
                                      ...t,
                                      'is_liked': !isLiked,
                                      'like_count':
                                      isLiked ? likeCount - 1 : likeCount + 1,
                                    }
                                  else
                                    t,
                              ];
                            },
                          ),
                          InkWell(
                            child: Text(likeCount > 0 ? '$likeCount' : ''),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) => const LikeList(),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => CommentBoard(id: id!),
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.chat_bubble,
                                    color: Color(0xFFD9D9D9)),
                                const SizedBox(width: 4),
                                Text(commentCount > 0 ? '$commentCount' : ''),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        content['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(content['content'] ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        formatted,
                        style: const TextStyle(color: Color(0xFF838383)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
