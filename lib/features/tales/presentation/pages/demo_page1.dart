import 'package:flutter/material.dart';



// ==========================================
// 1. Data Model (資料分離)
// 將 UI 與資料解耦，方便未來串接真實 API
// ==========================================
class PostModel {
  final String title;
  final String category;
  final String imageUrl;

  const PostModel({
    required this.title,
    required this.category,
    required this.imageUrl,
  });
}

// 模擬假資料
final List<PostModel> mockPosts = List.generate(
  6,
      (index) => PostModel(
    title: '標題文字',
    category: '旅遊',
    // 使用隨機圖片模擬不同貼文
    imageUrl: 'https://picsum.photos/seed/${index + 10}/400/600',
  ),
);

// ==========================================
// 2. Main Screen (主頁面架構)
// 使用 Scaffold 取代寫死的 Container 390x844
// ==========================================
class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 使用標準 SafeArea 避免劉海遮擋
      body: SafeArea(
        child: Column(
          children: [
            const _TopCategoryBar(), // 頂部標籤列
            const UploadProgressBar(), // 正在發佈貼文進度條
            // 使用 Expanded 讓 GridView 填滿剩餘可用空間
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  padding: const EdgeInsets.only(top: 12, bottom: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 兩欄佈局
                    mainAxisSpacing: 12, // 上下間距
                    crossAxisSpacing: 12, // 左右間距
                    childAspectRatio: 0.75, // 決定卡片的長寬比，取代寫死的 height: 250
                  ),
                  itemCount: mockPosts.length,
                  itemBuilder: (context, index) {
                    return PostCard(post: mockPosts[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _CustomBottomNavBar(),
    );
  }
}

// ==========================================
// 3. Extracted Components (組件化)
// 將重複的 UI 區塊抽取出來，提高可讀性與重用性
// ==========================================

/// 頂部標籤列 (包含橫向滑動列表與右側下拉按鈕)
class _TopCategoryBar extends StatelessWidget {
  const _TopCategoryBar();

  @override
  Widget build(BuildContext context) {
    final categories = ['全部', '旅遊', '學習', '挑戰', '冒險'];

    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 12, right: 4),
      child: Row(
        children: [
          // 使用 Expanded 讓 ListView 佔滿左側空間
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Center(
                  child: _CategoryChip(
                    label: categories[index],
                    isActive: index == 0, // 模擬第一個選項為啟動狀態
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            onPressed: () {}, // 實作下拉邏輯
          ),
        ],
      ),
    );
  }
}

/// 單一標籤樣式
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const _CategoryChip({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2C538A) : Colors.white,
        borderRadius: BorderRadius.circular(20), // 圓角膠囊形狀
        border: Border.all(color: const Color(0xFF2C538A), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF2C538A),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

/// 發佈進度條元件
class UploadProgressBar extends StatelessWidget {
  const UploadProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // 縮圖
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              'https://picsum.photos/40/40', // 模擬使用者大頭貼/縮圖
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          // 文字與進度條區塊
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '正在發佈貼文',
                  style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 6),
                // 漸層進度條 - 移除原本多餘的 Container，用簡潔的結構呈現
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: double.infinity, // 滿滿背景
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7E7E7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        // 模擬 60% 進度
                        width: constraints.maxWidth * 0.6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEDB60C), Color(0xFF24B7BD)], // Figma 的漸層色
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 貼文卡片元件
class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // 移除外部寫死的高寬 Container，依靠 GridView 的 childAspectRatio 決定尺寸
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 圖片佔用大部分空間
        Expanded(
          child: Stack(
            fit: StackFit.expand, // 讓圖片填滿 Stack
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              // 左上角分類標籤
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    post.category,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
              // 右上角收藏圖示
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.bookmark_border, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 底部標題與選單按鈕
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                post.title,
                style: const TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // 避免標題過長導致跑版
              ),
            ),
            const Icon(Icons.more_vert, size: 20, color: Color(0xFF333333)),
          ],
        ),
      ],
    );
  }
}

/// 底部導航列
class _CustomBottomNavBar extends StatelessWidget {
  const _CustomBottomNavBar();

  @override
  Widget build(BuildContext context) {
    // 使用原生的 BottomNavigationBar 替換複雜的 Container Stack
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -1)),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 確保 5 個 Icon 時不會自動隱藏標籤
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2C538A),
        unselectedItemColor: Colors.grey,
        elevation: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(
            // 發佈按鈕樣式
            icon: Icon(Icons.add_circle, size: 36),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            // 帶有 Badge 的通知圖示
            icon: Badge(
              label: const Text('10', style: TextStyle(fontSize: 10)),
              backgroundColor: const Color(0xFFE9416C),
              child: const Icon(Icons.notifications_none),
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}