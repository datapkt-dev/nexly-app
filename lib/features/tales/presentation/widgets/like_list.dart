import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../app/config/app_config.dart';
import '../../../../modules/profile/controller/profile_controller.dart';
import '../../../../modules/providers.dart';
import '../../../../unit/auth_service.dart';

class LikeList extends ConsumerStatefulWidget {
  final int id;
  const LikeList({super.key, required this.id});

  @override
  ConsumerState<LikeList> createState() => _LikeListState();
}

class _LikeListState extends ConsumerState<LikeList> {
  // bool followed = true;
  bool defaultHeight = false;

  late int id;
  late Future<Map<String, dynamic>> futureData;

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

  @override
  void initState() {
    super.initState();

    id = widget.id;
    futureData = getTaleContent(id);
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: defaultHeight ? 0.9 : 0.7,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
            // 把手
            const SizedBox(height: 10),
            GestureDetector(
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  defaultHeight = !defaultHeight;
                });
              },
            ),
            const SizedBox(height: 22),

            // 標題列
            Center(
              child: const Text(
                '按讚的用戶',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 18,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // 成員列表
            FutureBuilder(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text('載入發生錯誤'));
                }
                final likeList = snapshot.data!['data']['recent_likes'];

                return Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: likeList.length,
                    separatorBuilder: (_, __) => SizedBox.shrink(),
                    itemBuilder: (_, index) {
                      final likedUser = likeList[index];
                      bool followed = likedUser['is_following'] ?? false;

                      final userData = ref.watch(userProfileProvider);
                      bool self = likedUser['id'] == userData['id'];
                      return Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 9),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: ShapeDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(likedUser['avatar_url']),
                                      fit: BoxFit.cover,
                                    ),
                                    shape: OvalBorder(
                                      side: BorderSide(
                                        width: 2,
                                        color: const Color(0xFFE7E7E7),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${likedUser['name']}',
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4,),
                                    Text(
                                      '${likedUser['account']??'@datapkt.com.tw'}',
                                      style: const TextStyle(
                                        color: Color(0xFF898989),
                                        fontSize: 12,
                                        fontFamily: 'PingFang TC',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (!self) InkWell(
                            child: Container(
                              width: 88,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: followed ? ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFFD9E0E3),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ) : ShapeDecoration(
                                color: const Color(0xFF2C538A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: Text(
                                '${followed ? '取消' : ''}追蹤',
                                style: TextStyle(
                                  color: followed ? const Color(0xFF333333) : Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                // followed = !followed;
                                likedUser['is_following'] = !(likedUser['is_following'] ?? false);
                              });
                              final ProfileController profileController = ProfileController();
                              profileController.postFollow(likedUser['id']);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
