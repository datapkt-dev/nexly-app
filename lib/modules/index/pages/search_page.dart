import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexly/modules/index/widgets/SearchPageShimmer.dart';
import '../../../app/config/app_config.dart';
import '../../../features/tales/presentation/pages/tale_detail_page.dart';
import '../../../features/tales/presentation/widgets/tale_card.dart';
import '../../../unit/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/action_menu_bottom_sheet.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late Future<void> futureData;

  // 原有資料
  List group = ['挑戰', '學習', '旅遊'];
  final List<String> img = [
    'assets/images/landscape/goingup.jpg',
    'assets/images/landscape/egypt.jpg',
    'assets/images/postImg.png',
  ];

  // 搜尋相關
  final _focus = FocusNode();
  final _controller = TextEditingController();
  bool _isFocused = false;
  String get _query => _controller.text.trim();

  // 🔑 關鍵狀態：是否已送出搜尋
  bool _hasSubmitted = false;

  // 最近搜尋（保留，不影響顯示）
  final List<String> _recent = ['冒險', '旅行'];

  final ScrollController _scrollController = ScrollController();
  List tales = [];
  List categoryTales = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  String? keyword;

  // =========================
  // API
  // =========================
  Future<void> loadMoreTales() async {
    if (isLoading || !hasMore || keyword == null) return;

    setState(() {
      isLoading = true;
    });

    final result = await getTales(page, keyword!);
    final List newItems = result['data']['tales'];

    // ✅ 預載所有搜尋結果圖片，完成後再一次顯示
    if (newItems.isNotEmpty && mounted) {
      await Future.wait(
        newItems
            .where((item) => item['image_url'] != null && item['image_url'].toString().isNotEmpty)
            .map((item) => _precacheImage(item['image_url']))
            .toList(),
      );
    }

    if (!mounted) return;

    setState(() {
      page += 1;
      isLoading = false;
      if (newItems.isEmpty) hasMore = false;
      tales.addAll(newItems);
    });
  }

  Future<Map<String, dynamic>> getTales(int page, String? keyword) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final Uri url;
    if (keyword == null) {
      url = Uri.parse(
        '$baseUrl/tales/search?page_size=20&page=$page',
      );
    } else {
      url = Uri.parse(
        '$baseUrl/tales/search?title=$keyword&page_size=20&page=$page',
      );
    }
    print(url);

    String? token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);
      final responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      print('請求錯誤：$e');
      return {'data': {'items': []}};
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

    try {
      await http.post(url, headers: headers);
    } catch (e) {
      print('請求錯誤：$e');
    }
  }

  Future<List> getCategories() async {
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

    final List apiCategories = responseData['data'];

    return apiCategories;
  }

  Future<void> _initPage() async {
    final results = await Future.wait([
      getCategories(),
      getTales(1, null),
    ]);

    final categories = results[0] as List;
    final tales = (results[1] as Map)['data']['tales'] as List;

    // ✅ 預載所有分類圖片，全部完成後再一次顯示
    if (mounted) {
      await Future.wait(
        tales
            .where((t) => t['image_url'] != null && t['image_url'].toString().isNotEmpty)
            .map((t) => _precacheImage(t['image_url']))
            .toList(),
      );
    }

    group = categories;
    categoryTales = tales;
  }

  /// 預載單張圖片到快取
  Future<void> _precacheImage(String url) async {
    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
    } catch (_) {}
  }

  // =========================
  // lifecycle
  // =========================
  @override
  void initState() {
    super.initState();

    futureData = _initPage();

    _focus.addListener(() {
      setState(() => _isFocused = _focus.hasFocus);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        loadMoreTales();
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: !_hasSubmitted
                  ? (!_isFocused ? _buildCategoryView() : _buildRecentView()) // ✅ 送出前一律初始畫面
                  : _buildResultView(),  // ✅ 只有 Enter 才會進來
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // 搜尋列
  // =========================
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 34,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: ShapeDecoration(
              color: const Color(0xFFEEEEEE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: Color(0xFFABABAB)),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (value) {
                      final q = value.trim();
                      if (q.isEmpty) return;

                      keyword = q;
                      _hasSubmitted = true;

                      page = 1;
                      hasMore = true;
                      isLoading = false;

                      tales.clear();

                      setState(() {});
                      loadMoreTales();
                    },
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'PingFang TC',
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '搜尋關鍵字',
                      hintStyle: TextStyle(
                        color: Color(0xFFABABAB),
                        fontSize: 16,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_isFocused && _query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() {});
                    },
                    child: const Icon(Icons.clear,
                        size: 18, color: Color(0xFFABABAB)),
                  ),
              ],
            ),
          ),
        ),
        if (_isFocused)
          TextButton(
            onPressed: () {
              _controller.clear();
              _focus.unfocus();
              _hasSubmitted = false; // ✅ 回初始狀態
              setState(() {});
            },
            child: const Text(
              '取消',
              style: TextStyle(
                color: Color(0xFF2C538A),
                fontSize: 16,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  // =========================
  // 初始分類畫面（完全未改）
  // =========================
  Widget _buildCategoryView() {
    return FutureBuilder(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SearchPageShimmer();
        }
        return ListView.separated(
          itemCount: group.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final category = group[index];
            final categoryId = category['id'];
            // 🔑 關鍵：找出屬於此分類的貼文
            final List categoryPosts = categoryTales
                .where((tale) => tale['category_id'] == categoryId)
                .toList();
            if (categoryPosts.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Text(
                        group[index]['name'],
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 16,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categoryPosts.length, (i) {
                      final post = categoryPosts[i];
                      return GestureDetector(
                        child: Container(
                          width: 125,
                          height: 125,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFE7E7E7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: (post['image_url'] != null &&
                              post['image_url'].toString().isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: post['image_url'],
                                  fit: BoxFit.cover,
                                  width: 125,
                                  height: 125,
                                  placeholder: (_, __) => const SizedBox.shrink(),
                                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                )
                              : null,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => Post(id: post['id'],)),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        );
      },);
  }

  // 最近搜尋
  Widget _buildRecentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題 + 清除
        Row(
          children: [
            const Text(
              '最近搜尋紀錄',
              style: TextStyle(
                color: Color(0xFF838383),
                fontSize: 14,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_recent.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _recent.clear());
                },
                child: const Text(
                  '清除',
                  style: TextStyle(
                    color: Color(0xFF2C538A),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recent.isEmpty)
          const Text('目前沒有紀錄', style: TextStyle(color: Color(0xFF999999)))
        else
          Expanded(
            child: ListView.separated(
              itemCount: _recent.length,
              separatorBuilder: (_, __) => SizedBox.shrink(),
              itemBuilder: (_, i) {
                final term = _recent[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    term,
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 14,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onTap: () {
                    _controller.text = term;
                    _controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: _controller.text.length),
                    );
                    setState(() {}); // 會切到結果列表
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  // =========================
  // 搜尋結果
  // =========================
  Widget _buildResultView() {
    return GridView.builder(
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
            return const Center(child: CircularProgressIndicator());
          }
          if (!hasMore) {
            return const Center(
              child: Text('沒有更多貼文',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          return const SizedBox.shrink();
        }

        final taleContent = tales[index];
        final id = taleContent['id'];

        return TaleCard(
          networkImage: taleContent['image_url'] ?? '',
          tag: taleContent['category']['name'],
          title: taleContent['title'],
          isCollected: taleContent['is_favorited'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Post(id: id)),
            );
          },
          onCollectTap: () {
            postFavoriteTale(id);
            final willFavorite = !(taleContent['is_favorited'] as bool);
            setState(() {
              taleContent['is_favorited'] = willFavorite;
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
          onMoreTap: () {
            ActionMenuBottomSheet.show(
              context,
              rootContext: context,
              targetId: id,
              onCollect: () {
                postFavoriteTale(id);
                setState(() {
                  taleContent['is_favorited'] =
                  !(taleContent['is_favorited'] as bool);
                });
              },
            );
          },
        );
      },
    );
  }
}
