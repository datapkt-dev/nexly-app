import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nexly/components/widgets/upload_image_widget.dart';
import 'package:nexly/modules/index/pages/notification_page.dart';
import 'package:nexly/modules/index/pages/search_page.dart';
import '../../features/tales/presentation/pages/create_tale_page.dart';
import '../../features/tales/presentation/pages/tale_feed_page.dart';
import '../../unit/auth_service.dart';
import '../profile/profile.dart';
import '../providers.dart';
import 'controller/notification_controller.dart';

class Index extends ConsumerStatefulWidget {
  const Index({super.key});

  @override
  ConsumerState<Index> createState() => _IndexFrameState();
}

class _IndexFrameState extends ConsumerState<Index> {
  int contentIndex = 0;
  bool _wasUploading = false;
  int _profileKey = 0; // ✅ 用來強制 rebuild Profile
  final NotificationController _notificationController = NotificationController();

  Color _getItemColor(int index) {
    return contentIndex == index ? const Color(0xFF2C538A) : const Color(0xFFD1D1D1);
  }

  /// 從 API 取得未讀通知數量
  Future<void> _fetchUnreadCount() async {
    final count = await _notificationController.getUnreadCount();
    ref.read(unreadNotificationCountProvider.notifier).state = count;
  }

  Future<void> _loadData() async {
    // final current = ref.read(userProfileProvider);
    //
    // // ⭐ 已經有資料就直接跳過
    // if (current.isNotEmpty) {
    //   debugPrint('userProfileProvider 已有資料，略過讀取');
    //   return;
    // }

    final authStorage = AuthService();
    final result = await authStorage.getProfile();

    if (result == null) return;

    ref.read(userProfileProvider.notifier).state =
    Map<String, dynamic>.from(result);

    // ✅ 登入後立即預快取大頭照到磁碟快取
    final avatarUrl = result['avatar_url'];
    if (avatarUrl != null && avatarUrl.toString().isNotEmpty && mounted) {
      try {
        await precacheImage(CachedNetworkImageProvider(avatarUrl), context);
      } catch (_) {}
    }
  }

  // ✅ 保持非 Profile 頁面存活
  final IndexPage _indexPage = const IndexPage();
  final SearchPage _searchPage = const SearchPage();
  final NotificationPage _notificationPage = const NotificationPage();

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final userId = profile['id'] ?? 0;

    // ✅ 監聽上傳狀態
    final uploadState = ref.watch(uploadProgressProvider);
    final isUploading = uploadState.isUploading;

    // ✅ 上傳開始 → 自動切到動態牆
    if (isUploading && !_wasUploading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && contentIndex != 0) {
          setState(() {
            contentIndex = 0;
          });
        }
      });
    }

    // ✅ 上傳完成 → 強制 Profile 重建
    if (_wasUploading && !isUploading && uploadState.progress >= 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _profileKey++;
          });
        }
      });
    }
    _wasUploading = isUploading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: contentIndex,
        children: [
          _indexPage,
          _searchPage,
          _notificationPage,
          Profile(key: ValueKey('profile_${userId}_$_profileKey'), userId: userId),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 15,
              offset: Offset(0.0, 0.75),
            ),
          ],
        ),
        child: BottomAppBar(
          color: const Color(0xFFFFFFFF),
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavigationBarItem(
                0,
                'assets/icons/index_frame/home${contentIndex == 0 ? '_active' : ''}.svg',
                '首頁',
              ),
              _buildBottomNavigationBarItem(
                1,
                'assets/icons/index_frame/search${contentIndex == 1 ? '_active' : ''}.svg',
                '搜尋',
              ),
              const SizedBox(width: 25),
              UploadImageWidget(
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF2C538A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // 會變成圓角菱形
                      ),
                      shadows: [
                        BoxShadow(
                          color: const Color(0xFF2C538A).withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    // 內層：把 Icon 轉回 -45°，視覺上就是正的「＋」
                    child: Transform.rotate(
                      angle: -math.pi / 4,
                      child: const Icon(Icons.add, size: 18, color: Colors.white),
                    ),
                  ),
                ),
                onImagePicked: (imgRoute) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const NewPost()),
                  // );
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateTalePage(filePath: imgRoute,)),
                  );
                },
              ),
              const SizedBox(width: 25),
              _buildNotificationNavItem(),
              _buildBottomNavigationBarItem(
                3,
                'assets/icons/index_frame/user${contentIndex == 3 ? '_active' : ''}.svg',
                '會員',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildNotificationNavItem() {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            contentIndex = 2;
          });
          // ✅ 點鈴噹立即全部已讀 + 清紅點
          ref.read(unreadNotificationCountProvider.notifier).state = 0;
          _notificationController.postReadAll();
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  'assets/icons/index_frame/notification${contentIndex == 2 ? '_active' : ''}.svg',
                  width: 24,
                  height: 24,
                  color: _getItemColor(2),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9416C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Expanded _buildBottomNavigationBarItem(int index, String iconPath, String label) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            contentIndex = index;
          });
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              color: _getItemColor(index),
            ),
          ),
        ),
      ),
    );
  }

}
