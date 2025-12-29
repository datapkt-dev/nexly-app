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
  final ScrollController _scrollController = ScrollController();
  List tales = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true; // API 還有沒有下一頁

  Future<Map<String, dynamic>> futureData = Future.value({});

  bool _showOverlay = false;
  final List<String> tags = ['全部', '旅遊', '學習', '挑戰', '冒險',];
  List<bool> tagsActive = [true, false, false, false, false,];

  Future<Map<String, dynamic>> getTales(int page) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse('$baseUrl/projects/1/tales/others?page=$page&page_size=5');
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

  Future<void> loadMoreTales() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    final result = await getTales(page);

    final List newItems = result['data']['items'];

    setState(() {
      page += 1;
      tales.addAll(newItems);
      isLoading = false;

      if (newItems.isEmpty) {
        hasMore = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    loadMoreTales();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        loadMoreTales();
      }
    });
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
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 278,
                    ),
                    itemCount: tales.length + 1,
                    itemBuilder: (context, index) {
                      if (index == tales.length) {
                        if (isLoading) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (!hasMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                '沒有更多貼文',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      final taleContent = tales[index];
                      return TaleCard(
                        networkImage: taleContent['image_url'] ?? '',
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
