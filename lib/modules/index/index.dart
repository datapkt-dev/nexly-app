import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nexly/components/widgets/upload_image_widget.dart';
import 'package:nexly/modules/index/pages/notification_page.dart';
import 'package:nexly/modules/index/pages/search_page.dart';
import '../../features/tales/presentation/pages/create_tale_page.dart';
import '../../features/tales/presentation/pages/tale_feed_page.dart';
import '../../unit/auth_service.dart';
import '../profile/profile.dart';
import '../providers.dart';

class Index extends ConsumerStatefulWidget {
  const Index({super.key});

  @override
  ConsumerState<Index> createState() => _IndexFrameState();
}

class _IndexFrameState extends ConsumerState<Index> {
  int contentIndex = 0;

  Color _getItemColor(int index) {
    return contentIndex == index ? const Color(0xFF2C538A) : const Color(0xFFD1D1D1);
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

    // debugPrint('已存入 userProfileProvider: $result');
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildContent(),
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
                    MaterialPageRoute(builder: (context) => PostContentEdit(filePath: imgRoute,)),
                  );
                },
              ),
              const SizedBox(width: 25),
              _buildBottomNavigationBarItem(
                2,
                'assets/icons/index_frame/notification${contentIndex == 2 ? '_active' : ''}.svg',
                '通知',
              ),
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

  Expanded _buildBottomNavigationBarItem(int index, String iconPath, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            contentIndex = index;
          });
        },

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              color: _getItemColor(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (contentIndex) {
      case 0:
        return IndexPage();
      case 1:
        return SearchPage();
      case 2:
        return NotificationPage();
      case 3:
        // return PersonalPage();
        final profile = ref.read(userProfileProvider);
        return Profile.self(userId: profile['id'],);
      default:
        return const Center(child: Text("尚未開放"));
    }
  }
}
