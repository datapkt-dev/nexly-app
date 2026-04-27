import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexly/modules/progress/widgets/StatsCard.dart';
import '../../app/config/app_config.dart';
import '../../unit/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Progress extends StatefulWidget {
  final int userId;
  const Progress({super.key, required this.userId});

  @override
  State<Progress> createState() => _ProgressState();
}

class _ProgressState extends State<Progress> {
  List<String> titles = ['個人', '團體',];
  List<String> tags = ['最近完成活動', '未完成活動',];
  int current = 0;
  int selectedTag = 0;


  late int userId;
  late Future<Map<String, dynamic>> futureData;

  Future<Map<String, dynamic>> getAchievement(id) async {
    final String baseUrl = AppConfig.baseURL;
    final AuthService authStorage = AuthService();

    final url = Uri.parse('$baseUrl/users/$id/achievements');
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
    userId = widget.userId;
    futureData = getAchievement(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            image: const DecorationImage(
              image: AssetImage('assets/images/progress_bg.png'),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
          foregroundDecoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6), // 直接一層黑紗
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '${titles[current]}成就',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: FutureBuilder(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '發生錯誤: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              }
              final achievements = snapshot.data?['data'];
              final personal = achievements['personal_tales']['tales'];
              final group = achievements['co_tales']['tales'];
              final List data = [personal, group];
              return Column(
                children: [
                  StatsCarousel(
                    achievements: achievements,
                    onIndexChanged: (i) {
                      setState(() => current = i);
                      // 這裡可以做任何事，例如切換說明文字、記錄事件等
                      // debugPrint('目前在第 $i 張卡片');
                    },
                  ),
                  SizedBox(height: 30,),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(top: 20, left: 16, right: 16,),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 32,
                            padding: const EdgeInsets.all(2),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(99),
                              ),
                              shadows: const [
                                BoxShadow(
                                  color: Color(0x26000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final tabCount = tags.length;
                                final tabWidth = constraints.maxWidth / tabCount;
                                return Stack(
                                  children: [
                                    AnimatedPositioned(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      left: selectedTag * tabWidth,
                                      top: 0,
                                      bottom: 0,
                                      width: tabWidth,
                                      child: Container(
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFF46C3F),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(99),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(tabCount, (index) {
                                        return Expanded(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              setState(() {
                                                selectedTag = index;
                                              });
                                            },
                                            child: Center(
                                              child: AnimatedDefaultTextStyle(
                                                duration: const Duration(milliseconds: 250),
                                                style: TextStyle(
                                                  color: selectedTag == index
                                                      ? Colors.white
                                                      : const Color(0xFF333333),
                                                  fontSize: 14,
                                                  fontFamily: 'PingFang TC',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                child: Text(tags[index]),
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Builder(builder: (_) {
                              // ✅ 根據 tab 篩選：0 = 已完成、1 = 未完成
                              final List rawList = data[current] ?? [];
                              final List filtered = rawList.where((t) {
                                final completed = t['is_completed'] == true;
                                return selectedTag == 0 ? completed : !completed;
                              }).toList();

                              // 已完成依 completed_at 倒序、未完成依 created_at 倒序
                              filtered.sort((a, b) {
                                final keyA = (selectedTag == 0
                                        ? a['completed_at']
                                        : a['created_at']) ??
                                    '';
                                final keyB = (selectedTag == 0
                                        ? b['completed_at']
                                        : b['created_at']) ??
                                    '';
                                return keyB.toString().compareTo(keyA.toString());
                              });

                              if (filtered.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Text(
                                      selectedTag == 0
                                          ? '尚無完成的活動'
                                          : '尚無未完成的活動',
                                      style: const TextStyle(
                                        color: Color(0xFF838383),
                                        fontSize: 14,
                                        fontFamily: 'PingFang TC',
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                                itemCount: filtered.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                  final item = filtered[index];
                                String formatDate(String iso) {
                                  final dt = DateTime.parse(iso).toLocal();
                                  return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
                                }
                                  // 已完成顯示 completed_at；未完成顯示 created_at
                                  final dateStr = (selectedTag == 0
                                          ? (item['completed_at'] ?? item['created_at'])
                                          : item['created_at']) ??
                                      '';
                                  final imageUrl = (item['image_url'] ?? '').toString();
                                return Row(
                                  children: [
                                      // 圖片卡（沒圖時顯示佔位）
                                    Container(
                                      width: 125,
                                      height: 95,
                                      decoration: ShapeDecoration(
                                          color: const Color(0xFFE7E7E7),
                                          image: imageUrl.isNotEmpty
                                              ? DecorationImage(
                                                  image: NetworkImage(imageUrl),
                                          fit: BoxFit.cover,
                                                )
                                              : null,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                        child: imageUrl.isEmpty
                                            ? const Icon(Icons.image_outlined,
                                                color: Colors.grey)
                                            : null,
                                    ),
                                    const SizedBox(width: 20),
                                      // 右側文字
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item['title']}',
                                              style: const TextStyle(
                                              color: Color(0xFF333333),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                            const SizedBox(height: 6),
                                            if (dateStr.toString().isNotEmpty)
                                          Text(
                                                formatDate(dateStr.toString()),
                                                style: const TextStyle(
                                              color: Color(0xFF24B7BD),
                                              fontSize: 14,
                                              fontFamily: 'PingFang TC',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
