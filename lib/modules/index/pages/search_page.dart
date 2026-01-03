import 'package:flutter/material.dart';
import '../../../features/tales/presentation/pages/tale_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 你原有資料
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

  // 簡單的最近搜尋（可改為 SharedPreferences 持久化）
  final List<String> _recent = ['冒險', '旅行'];

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _isFocused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  // ====== UI ======

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildSearchBar(),
            // 主體：依狀態切換
            Expanded(
              child: !_isFocused
                  ? _buildCategoryView()            // 初始狀態
                  : (_query.isEmpty
                  ? _buildRecentView()           // 聚焦但未輸入
                  : _buildResultView(_query)),   // 有輸入
            ),
          ],
        ),
      ),
    );
  }

  // 搜尋列（含取消）
  Widget _buildSearchBar() {
    return Row(
      children: [
        // 搜尋輸入框
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
                // 清除輸入鈕（有字時顯示）
                if (_isFocused && _query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() {});
                    },
                    child: const Icon(Icons.clear, size: 18, color: Color(0xFFABABAB)),
                  ),
              ],
            ),
          ),
        ),
        // 取消（聚焦時顯示）
        if (_isFocused)
          TextButton(
            onPressed: () {
              _controller.clear();
              _focus.unfocus();
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

  // 初始狀態：分類 + 橫向圖片（沿用你的設計）
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Post()),
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

  // 搜尋結果（示範用：用關鍵字造兩筆假資料）
  Widget _buildResultView(String q) {
    final results = List.generate(2, (i) => '$q關鍵字項目${i + 1}');
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, __) => SizedBox.shrink(),
      itemBuilder: (_, i) {
        final text = results[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            text,
            style: TextStyle(
              color: const Color(0xFF333333),
              fontSize: 14,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w400,
            ),
          ),
          onTap: () {
            // TODO: 進入結果頁 or 執行實際搜尋
            // 收起鍵盤
            _focus.unfocus();
            // 存進最近搜尋（避免重複）
            if (q.isNotEmpty) {
              _recent.remove(q);
              _recent.insert(0, q);
              if (_recent.length > 10) _recent.removeLast();
            }
            setState(() {});
          },
        );
      },
    );
  }
}
