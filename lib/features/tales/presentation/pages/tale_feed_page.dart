import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nexly/features/tales/presentation/pages/tale_detail_page.dart';
import '../../../../app/config/app_config.dart';
import '../../../../modules/index/widgets/action_menu_bottom_sheet.dart';
import '../../../../unit/auth_service.dart';
import '../widgets/filter_overlay.dart';
import '../widgets/tag_selector.dart';
import '../widgets/tale_card.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexState();
}

class _IndexState extends State<IndexPage> {
  Future<Map<String, dynamic>> futureData = Future.value({});

  bool _showOverlay = false;
  final List<String> tags = ['全部', '旅遊', '學習', '挑戰', '冒險',];
  List<bool> tagsActive = [true, false, false, false, false,];
  final List<String> img = [
    'assets/images/landscape/dog.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/hiking.jpg',
  ];
  List<bool> collected = [true, false, false, false, false, false,];

  Future<Map<String, dynamic>> getTales() async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse('$baseUrl/projects/1/tales/others');
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
    futureData = getTales();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10,),
                  child: Row(
                    children: [
                      Expanded(
                        child: TagSelector(
                          tags: tags,
                          active: tagsActive,
                          scrollable: true,
                          onTap: (index) {
                            setState(() {
                              if (index == 0) {
                                for (int i = 0; i < tagsActive.length; i++) {
                                  tagsActive[i] = (i == 0);
                                }
                              } else {
                                tagsActive[0] = false;
                                tagsActive[index] = !tagsActive[index];
                              }
                            });
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showOverlay = true;
                          });
                        },
                        child: Icon(Icons.expand_more),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
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
                      List tales = [];
                      if (snapshot.data?['data']['items'].isNotEmpty) {
                        tales = snapshot.data?['data']['items'];
                      }
                      return SingleChildScrollView(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(0),
                          shrinkWrap: true, // 高度隨內容變化
                          physics: NeverScrollableScrollPhysics(), // 交給外層滾動
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 278,   // ✅ 固定每個 item 的高度 (250 圖片 + 文字空間)
                          ),
                          itemCount: tales.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> taleContent = tales[index];
                            final String imageUrl =
                            (taleContent['image_url'] is String && taleContent['image_url'].toString().isNotEmpty)
                                ? taleContent['image_url']
                                : '';
                            return TaleCard(
                              networkImage: imageUrl,
                              tag: taleContent['category']['name'],
                              title: taleContent['title'],
                              isCollected: taleContent['is_favorited'],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => Post(id: taleContent['id'],)),
                                );
                              },
                              onCollectTap: () {
                                // setState(() {
                                //   collected[index] = !collected[index];
                                // });
                              },
                              onMoreTap: () {
                                ActionMenuBottomSheet.show(
                                  context,
                                  rootContext: context,
                                  targetId: 'post_123',
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          FilterOverlay(
            show: _showOverlay,
            tags: tags,
            active: tagsActive,
            onClose: () {
              setState(() {
                _showOverlay = false;
              });
            },
            onTagTap: (index) {
              setState(() {
                if (index == 0) {
                  for (int i = 0; i < tagsActive.length; i++) {
                    tagsActive[i] = (i == 0);
                  }
                } else {
                  tagsActive[0] = false;
                  tagsActive[index] = !tagsActive[index];
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
