import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/config/app_config.dart';
import '../../../features/tales/di/tales_providers.dart';
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
  // 原有資料
  final List<String> group = ['挑戰', '學習', '旅遊'];
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
    print(result['data']['tales']);
    final List newItems = result['data']['tales'];

    setState(() {
      page += 1;
      isLoading = false;
      if (newItems.isEmpty) hasMore = false;
      tales.addAll(newItems); // ✅ 關鍵
    });

    ref.read(talesFeedProvider.notifier).state = [
      ...ref.read(talesFeedProvider),
      ...newItems,
    ];
  }

  Future<Map<String, dynamic>> getTales(int page, String keyword) async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse(
      '$baseUrl/tales/search?title=$keyword&page_size=20&page=$page',
    );
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

  // =========================
  // lifecycle
  // =========================
  @override
  void initState() {
    super.initState();

    _focus.addListener(() {
      setState(() => _isFocused = _focus.hasFocus);
    });

    Future.microtask(() {
      ref.read(talesFeedProvider.notifier).state = [];
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
                      ref.read(talesFeedProvider.notifier).state = [];

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
    return ListView.separated(
      itemCount: group.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Text(
                    group[index],
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
                children: List.generate(6, (i) {
                  return GestureDetector(
                    child: Container(
                      width: 125,
                      height: 125,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: AssetImage(img[i % 3]),
                          fit: BoxFit.cover,
                        ),
                        color: const Color(0xFFE7E7E7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (_) => Post()),
                      // );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
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
            setState(() {
              taleContent['is_favorited'] =
              !(taleContent['is_favorited'] as bool);
            });
          },
          onMoreTap: () {
            ActionMenuBottomSheet.show(
              context,
              rootContext: context,
              targetId: 'post_$id',
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
