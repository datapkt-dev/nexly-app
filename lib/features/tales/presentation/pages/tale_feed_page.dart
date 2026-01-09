import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexly/features/tales/presentation/pages/tale_detail_page.dart';
import '../../../../app/config/app_config.dart';
import '../../../../modules/index/widgets/action_menu_bottom_sheet.dart';
import '../../../../unit/auth_service.dart';
import '../../di/tales_providers.dart';
import '../widgets/filter_overlay.dart';
import '../widgets/tag_selector.dart';
import '../widgets/tale_card.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({super.key});

  @override
  ConsumerState<IndexPage> createState() => _IndexState();
}

class _IndexState extends ConsumerState<IndexPage> {
  final ScrollController _scrollController = ScrollController();
  // List tales = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true; // API 還有沒有下一頁

  Future<Map<String, dynamic>> futureData = Future.value({});

  bool _showOverlay = false;
  List<Map<String, dynamic>> tags = [];
  List<bool> tagsActive = [true, false, false, false, false,];

  Future<List<Map<String, dynamic>>> getCategories() async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse('$baseUrl/projects/1/categories');
    final token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);
    final responseData = jsonDecode(response.body);

    final List apiCategories = responseData['data'] as List;

    return [
      // ⭐「全部」固定在第一筆
      {
        'id': 0,
        'name': '全部',
        'is_active': true,
      },

      // ⭐ API 原資料完整保留，只改 is_active
      ...apiCategories.map<Map<String, dynamic>>(
            (c) => {
          ...Map<String, dynamic>.from(c),
          'is_active': false,
        },
      ),
    ];
  }

  Future<void> _initPage() async {
    final result = await getCategories();

    setState(() {
      tags = result;
    });

    loadMoreTales();
  }

  Future<Map<String, dynamic>> getTales(int page, List selectedTags) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    // 判斷是否為「全部」
    final bool isAll =
        selectedTags.isEmpty ||
            (selectedTags.length == 1 && selectedTags.first == 0);

    // 組 query
    final query = isAll
        ? 'page=$page&page_size=5'
        : 'page=$page&page_size=5&category_id=${selectedTags.join(',')}';

    final url = Uri.parse('$baseUrl/projects/1/tales/others?$query');

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

    final List<int> selected =
    tags.where((tag) => tag['is_active'] == true)
        .map<int>((tag) => tag['id'] as int)
        .toList();
    final result = await getTales(page, selected);

    final List newItems = result['data']['items'];

    setState(() {
      page += 1;
      isLoading = false;
      if (newItems.isEmpty) hasMore = false;
    });

    // ✅ 同步更新 Riverpod 共用狀態
    ref.read(talesFeedProvider.notifier).state = [
      ...ref.read(talesFeedProvider),
      ...newItems,
    ];
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

  Future<void> _reloadTales() async {
    // 重置分頁狀態
    page = 1;
    hasMore = true;
    isLoading = false;

    // 清空舊資料
    ref.read(talesFeedProvider.notifier).state = [];

    // 重新抓第一頁
    await loadMoreTales();
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(talesFeedProvider.notifier).state = [];
    });

    _initPage();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        loadMoreTales();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tales = ref.watch(talesFeedProvider);

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
                          tags: tags.map((e) => e['name'] as String).toList(),
                          active: tags.map((e) => e['is_active'] as bool).toList(),
                          scrollable: true,
                          onTap: (index) async {
                            setState(() {
                              if (index == 0) {
                                // 🟢 點「全部」：其他全部關閉
                                for (int i = 0; i < tags.length; i++) {
                                  tags[i]['is_active'] = i == 0;
                                }
                              } else {
                                // 🟡 點其他分類：可多選
                                tags[0]['is_active'] = false; // 「全部」一定關閉
                                tags[index]['is_active'] = !(tags[index]['is_active'] as bool);
                              }
                            });

                            await _reloadTales();
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
                          final id = taleContent['id'];
                          postFavoriteTale(id);
                          ref.read(talesFeedProvider.notifier).state = [
                            for (final tale in ref.read(talesFeedProvider))
                              if (tale['id'] == id)
                                {
                                  ...tale,
                                  'is_favorited': !(tale['is_favorited'] as bool),
                                }
                              else
                                tale,
                          ];
                        },
                        onMoreTap: () {
                          final id = taleContent['id'];
                          ActionMenuBottomSheet.show(
                            context,
                            rootContext: context,
                            targetId: 'post_123',
                            onCollect: () {
                              postFavoriteTale(id);

                              ref.read(talesFeedProvider.notifier).state = [
                                for (final tale in ref.read(talesFeedProvider))
                                  if (tale['id'] == id)
                                    {
                                      ...tale,
                                      'is_favorited': !(tale['is_favorited'] as bool),
                                    }
                                  else
                                    tale,
                              ];
                            },
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
            tags: tags.map((e) => e['name'] as String).toList(),
            active: tags.map((e) => e['is_active'] as bool).toList(),
            onClose: () {
              setState(() {
                _showOverlay = false;
              });
            },
            onTagTap: (index) async {
              setState(() {
                if (index == 0) {
                  // 🟢 點「全部」：其他全部關閉
                  for (int i = 0; i < tags.length; i++) {
                    tags[i]['is_active'] = i == 0;
                  }
                } else {
                  // 🟡 點其他分類：可多選
                  tags[0]['is_active'] = false; // 「全部」一定關閉
                  tags[index]['is_active'] = !(tags[index]['is_active'] as bool);
                }
              });

              await _reloadTales();
            },
          ),
        ],
      ),
    );
  }
}
