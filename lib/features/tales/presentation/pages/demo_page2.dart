import 'package:flutter/material.dart';



// ==========================================
// 1. Data Models (資料處理與模擬)
// ==========================================
class PostModel {
  final String imageUrl;
  final bool hasPremiumBadge;

  const PostModel({
    required this.imageUrl,
    this.hasPremiumBadge = false,
  });
}

// 模擬使用者的貼文圖片資料
final List<PostModel> mockPosts = List.generate(
  10,
      (index) => PostModel(
    imageUrl: 'https://picsum.photos/seed/${index + 50}/400/500',
    hasPremiumBadge: index < 2, // 模擬前兩張帶有特殊徽章
  ),
);

// ==========================================
// 2. Main Screen (主頁面 - 使用 Sliver 架構)
// ==========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 規則 4: 使用原生 Scaffold 與 AppBar
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      // 這裡改用 CustomScrollView + Slivers 來處理「頂部資訊」與「底部網格」的聯動滾動
      body: CustomScrollView(
        slivers: [
          // 頂部非網格的 UI 區塊，使用 SliverToBoxAdapter 包裝
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ProfileHeader(), // 規則 3: 元件化 - 個人大頭貼與名稱
                  SizedBox(height: 16),
                  ProfileStats(), // 規則 3: 元件化 - 粉絲與追蹤數據
                  SizedBox(height: 16),
                  ProfileBio(), // 規則 3: 元件化 - 自我介紹
                  SizedBox(height: 20),
                  AchievementCard(), // 規則 3: 元件化 - 成就進度卡片
                  SizedBox(height: 20),
                  CustomTabBar(), // 規則 3: 元件化 - 標籤切換列
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // 規則 1 & 2: 使用 SliverGrid 取代寫死的 Stack 排版
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 兩欄
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8, // 響應式控制卡片長寬比
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => ImageGridCard(post: mockPosts[index]),
                childCount: mockPosts.length,
              ),
            ),
          ),
          // 底部留白
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
      bottomNavigationBar: const _CustomBottomNavBar(),
    );
  }
}

// ==========================================
// 3. Extracted Components (組件化提取)
// ==========================================

/// 個人資料頭像與名稱區塊
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // 規則 1: 改用 Row 進行水平排版
    return Row(
      children: [
        const CircleAvatar(
          radius: 32,
          backgroundImage: NetworkImage("https://picsum.photos/100"), // 替換為真實圖片
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Text(
                  'Sam ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                Text('🇹🇼', style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'sam9527',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        )
      ],
    );
  }
}

/// 數據統計區塊 (100 Tales, 1000 粉絲...)
class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Wrap 讓數據在小螢幕時自動換行，防止 Overflow
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _StatItem(count: '100', label: 'Tales'),
        _StatItem(count: '1000', label: '粉絲'),
        _StatItem(count: '1234', label: '追蹤中'),
        _StatItem(count: '100', label: 'Trusted Circle'),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF333333), fontSize: 14, fontFamily: 'PingFang TC'),
        children: [
          TextSpan(text: '$count ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: label),
        ],
      ),
    );
  }
}

/// 個人簡介
class ProfileBio extends StatelessWidget {
  const ProfileBio({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '個人簡介寫在這裡，個人簡介寫在這裡個人簡介寫在這裡，個人簡介寫在這裡',
      style: TextStyle(fontSize: 14, color: Color(0xFF333333), height: 1.5),
    );
  }
}

/// 成就進度卡片 (漸層背景)
class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 規則 2: width 使用 double.infinity 適應螢幕寬度
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF24B7BD), Color(0xFF2C538A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('progress 成就', style: TextStyle(color: Colors.white, fontSize: 16)),
              Icon(Icons.chevron_right, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar('個人', '10/42', 0.25, '25%'),
          const SizedBox(height: 16),
          _buildProgressBar('團體', '10/42', 0.50, '50%'),
        ],
      ),
    );
  }

  // 規則 5: 清理複雜嵌套，改用原生的 LinearProgressIndicator
  Widget _buildProgressBar(String title, String ratio, double progress, String percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title  $ratio', style: const TextStyle(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEDB60C)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(percentage, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

/// 中間的 Tab 切換區塊
class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTabItem('Tales', isActive: true),
        _buildTabItem('協作', isActive: false),
        _buildTabItem('收藏', isActive: false),
      ],
    );
  }

  Widget _buildTabItem(String label, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF46C3F) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF333333),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// 網格圖片卡片
class ImageGridCard extends StatelessWidget {
  final PostModel post;

  const ImageGridCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // 規則 1 & 5: 這是全篇唯一合理保留 Stack 的地方，用於將黃色徽章疊加在圖片上
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        if (post.hasPremiumBadge)
          const Positioned(
            top: 8,
            left: 8,
            child: Icon(Icons.workspace_premium, color: Color(0xFFEDB60C), size: 28),
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
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEBEBF0), width: 1)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2C538A),
        unselectedItemColor: Colors.grey,
        currentIndex: 4, // 模擬停留在「個人」頁面
        elevation: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          const BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 36), label: 'Add'),
          BottomNavigationBarItem(
            icon: Badge(
              label: const Text('10', style: TextStyle(fontSize: 10)),
              backgroundColor: const Color(0xFFE9416C),
              child: const Icon(Icons.notifications_none),
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}