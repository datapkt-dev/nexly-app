import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexly/features/tales/presentation/pages/tale_detail_page.dart';
import '../../../../app/config/app_config.dart';
import '../../../../modules/index/widgets/action_menu_bottom_sheet.dart';
import '../../../../modules/index/widgets/upload_progress_overlay.dart';
import '../../../../modules/providers.dart';
import '../../../../unit/auth_service.dart';
import '../widgets/TaleCardShimmer.dart';
import '../widgets/filter_overlay.dart';
import '../widgets/tag_selector.dart';
import '../widgets/tale_card.dart';

class IndexPage extends ConsumerStatefulWidget {
  const IndexPage({super.key});

  @override
  ConsumerState<IndexPage> createState() => _IndexState();
}

class _IndexState extends ConsumerState<IndexPage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _tales = []; // ✅ local list 驅動 GridView
  int _visibleCount = 0; // ✅ 控制實際顯示的卡片數量，確保同批同時出現
  int _prevVisibleCount = 0; // ✅ 上一批已顯示的數量（這些卡片保持 opacity=1）
  bool _batchReady = false; // ✅ 新批次卡片是否已就緒（控制整批同時顯示）
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;

  Future<Map<String, dynamic>> futureData = Future.value({});

  bool _showOverlay = false;
  List<Map<String, dynamic>> tags = [];
  List<bool> tagsActive = [true, false, false, false, false, false, false,];

  Future<List<Map<String, dynamic>>> getCategories() async {
    final AuthService authStorage = AuthService();
    final String baseUrl = AppConfig.baseURL;

    final url = Uri.parse('$baseUrl/categories');
    final token = await authStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
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
    } catch (e) {
      print('getCategories 錯誤：$e');
      return [
        {
          'id': 0,
          'name': '全部',
          'is_active': true,
        },
      ];
    }
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

    final url = Uri.parse('$baseUrl/tales?$query');

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

    // 檢查 API 是否成功
    if (result['error'] != null || result['data'] == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    final List newItems = result['data']['items'] ?? [];

    if (!mounted) return;

    final typedItems = newItems
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    // ✅ 先加入 _tales（但 _visibleCount 還沒更新，所以 UI 不會顯示這些新卡片）
    _tales.addAll(typedItems);

    // ✅ 預載所有圖片到記憶體快取，並 resolve ImageProvider 確保 bitmap 就緒
    if (typedItems.isNotEmpty && mounted) {
      final futures = typedItems
          .where((item) => item['image_url'] != null && item['image_url'].toString().isNotEmpty)
          .map((item) => _precacheAndResolve(item['image_url']))
          .toList();
      await Future.wait(futures);
    }

    if (!mounted) return;

    // ✅ 圖片 bitmap 全部就緒，一次性更新 _visibleCount
    //    但先用 _batchReady = false 讓 Opacity=0，等一幀 build 完再顯示
    setState(() {
      page += 1;
      isLoading = false;
      _prevVisibleCount = _visibleCount; // 記住舊的數量
      _batchReady = false;
      _visibleCount = _tales.length;
      if (newItems.isEmpty) hasMore = false;
    });

    // ✅ 等兩幀：第一幀 build widget tree，第二幀 layout + paint 完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _batchReady = true;
          });
        }
      });
    });
  }

  /// 預載圖片到記憶體快取，並 resolve ImageProvider 確保 bitmap 已就緒
  Future<void> _precacheAndResolve(String url) async {
    try {
      final provider = CachedNetworkImageProvider(url);
      await precacheImage(provider, context);
      // 額外 resolve 確保 ImageStream 已完成，bitmap 在 memory cache 裡
      final stream = provider.resolve(ImageConfiguration.empty);
      final completer = Completer<void>();
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (_, __) {
          stream.removeListener(listener);
          if (!completer.isCompleted) completer.complete();
        },
        onError: (_, __) {
          stream.removeListener(listener);
          if (!completer.isCompleted) completer.complete();
        },
      );
      stream.addListener(listener);
      await completer.future;
    } catch (_) {}
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
      final response = await http.post(url, headers: headers,);
      final responseData = jsonDecode(response.body);
      print(responseData);
    } catch (e) {
      print('請求錯誤：$e');
    }
  }

  Future<void> _reloadTales() async {
    // 重置分頁狀態
    page = 1;
    hasMore = true;
    isLoading = false;

    setState(() {
      _tales.clear();
      _visibleCount = 0;
      _prevVisibleCount = 0;
      _batchReady = false;
    });

    // 重新抓第一頁
    await loadMoreTales();
  }

  Future<void> _onRefresh() async {
    await _reloadTales();
  }

  @override
  void initState() {
    super.initState();

    if (_tales.isEmpty) {
      _initPage();
    }

    _scrollController.addListener(() {
      // ✅ 提前預載：距離底部 200px 時開始載入下一頁
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200 &&
          position.maxScrollExtent > 0) {
        loadMoreTales();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _wasUploading = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ✅ 監聽上傳進度：完成時顯示 SnackBar
    final uploadState = ref.watch(uploadProgressProvider);
    if (_wasUploading && !uploadState.isUploading && uploadState.progress >= 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '發佈成功 🎉',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
      });
    }
    _wasUploading = uploadState.isUploading;

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
                // ✅ 發文進度條 — 在標籤列下方、GridView 上方
                const UploadProgressOverlay(),
                Expanded(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: uploadState.isUploading
                              ? const NeverScrollableScrollPhysics()
                              : const AlwaysScrollableScrollPhysics(),
                          cacheExtent: 1500,
                          slivers: [
                        // ===== 首次載入 shimmer =====
                        if (_visibleCount == 0 && isLoading)
                          SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 278,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => const TaleCardShimmer(),
                              childCount: 4,
                            ),
                          ),

                        // ===== 貼文卡片 =====
                        if (_visibleCount > 0)
                          SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 278,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              addAutomaticKeepAlives: true,
                              (context, index) {
                                final taleContent = _tales[index];
                                // ✅ 舊卡片永遠可見，新卡片等整批就緒才同時出現
                                final isOldCard = index < _prevVisibleCount;
                                final opacity = isOldCard || _batchReady ? 1.0 : 0.0;
                                return Opacity(
                                  opacity: opacity,
                                  child: TaleCard(
                                  key: ValueKey(taleContent['id']),
                                  heroTag: taleContent['id'],
                                  networkImage: taleContent['image_url'] ?? '',
                                  tag: taleContent['category']['name'],
                                  title: taleContent['title'],
                                  isCollected: taleContent['is_favorited'],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => Post(
                                          id: taleContent['id'],
                                          previewData: taleContent,
                                        ),
                                      ),
                                    ).then((result) {
                                      if (result == 'refresh') {
                                        _reloadTales();
                                      }
                                    });
                                  },
                                  onCollectTap: () {
                                    HapticFeedback.lightImpact();
                                    final id = taleContent['id'];
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
                                    final id = taleContent['id'];
                                    ActionMenuBottomSheet.show(
                                      context,
                                      rootContext: context,
                                      targetId: id,
                                      onCollect: () {
                                        postFavoriteTale(id);
                                        setState(() {
                                          taleContent['is_favorited'] = !(taleContent['is_favorited'] as bool);
                                        });
                                      },
                                    );
                                  },
                                ),
                                );
                              },
                              childCount: _visibleCount,
                            ),
                          ),

                        // ===== 底部：載入中 shimmer 或「沒有更多貼文」=====
                        if (_visibleCount > 0 && isLoading)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: const [
                                  Expanded(child: TaleCardShimmer()),
                                  SizedBox(width: 6),
                                  Expanded(child: TaleCardShimmer()),
                                ],
                              ),
                            ),
                          ),

                        if (!hasMore && _visibleCount > 0)
                          const SliverToBoxAdapter(
                            child: Padding(
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
                            ),
                          ),
                      ],
                    ),
                  ),
                  // ✅ 上傳中：霧面遮罩覆蓋文章區域
                  if (uploadState.isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    ],
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

  @override
  bool get wantKeepAlive => true;
}
