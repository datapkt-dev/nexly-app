import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nexly_temp/components/widgets/upload_image_widget.dart';
import 'package:nexly_temp/modules/index/pages/notification_page.dart';
import 'package:nexly_temp/modules/new_post/new_post.dart';
import '../new_post/pages/post_content_edit.dart';
import 'pages/index_page.dart';
import 'pages/search_page.dart';
import 'pages/personal_page.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexFrameState();
}

class _IndexFrameState extends State<Index> {
  int contentIndex = 0;

  Color _getItemColor(int index) {
    return contentIndex == index ? const Color(0xFF454545) : const Color(0xFFD1D1D1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: contentIndex == 0
      //     ? Drawer(
      //   backgroundColor: Colors.white,
      //   child: ListView(
      //     children: [
      //       Container(
      //         margin: EdgeInsets.symmetric(horizontal: 20,),
      //         child: Row(
      //           children: [
      //             Container(
      //               width: 60,
      //               height: 60,
      //               decoration: ShapeDecoration(
      //                 color: const Color(0xFFD9D9D9),
      //                 shape: RoundedRectangleBorder(
      //                   borderRadius: BorderRadius.circular(100),
      //                 ),
      //               ),
      //             ),
      //             const SizedBox(width: 16,),
      //             const Column(
      //               mainAxisSize: MainAxisSize.min,
      //               children: [
      //                 Text(
      //                   'User Name',
      //                   style: TextStyle(
      //                     color: const Color(0xFF333333),
      //                     fontSize: 16,
      //                     fontFamily: 'PingFang TC',
      //                     fontWeight: FontWeight.w400,
      //                   ),
      //                 ),
      //                 SizedBox(height: 10,),
      //                 Text(
      //                   '＠Aa1234567',
      //                   style: TextStyle(
      //                     color: const Color(0xFF838383),
      //                     fontSize: 14,
      //                     fontFamily: 'PingFang TC',
      //                     fontWeight: FontWeight.w400,
      //                     height: 1.25,
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //       SizedBox(height: 20,),
      //       ListTile(
      //         title: Text(
      //           '我的邀請碼',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {
      //           // Navigator.push(
      //           //   context,
      //           //   MaterialPageRoute(builder: (context) => const Invitation()),
      //           // );
      //         },
      //       ),
      //       ListTile(
      //         title: Text(
      //           '會員中心',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {
      //           // Navigator.push(
      //           //   context,
      //           //   MaterialPageRoute(builder: (context) => const MemberCenter()),
      //           // );
      //         },
      //       ),
      //       ListTile(
      //         title: Text(
      //           '預約記錄',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {
      //           // Navigator.push(
      //           //   context,
      //           //   MaterialPageRoute(builder: (context) => const Appointment()),
      //           // );
      //         },
      //       ),
      //       ListTile(
      //         title: Text(
      //           '瀏覽記錄',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {
      //           // Navigator.push(
      //           //   context,
      //           //   MaterialPageRoute(builder: (context) => const History()),
      //           // );
      //         },
      //       ),
      //       ListTile(
      //         title: Text(
      //           '求職',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text(
      //           '商城',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text(
      //           '條款',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text(
      //           '客服',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text(
      //           '設定',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {},
      //       ),
      //       ListTile(
      //         title: Text(
      //           '登出',
      //           style: TextStyle(
      //             color: const Color(0xFF333333),
      //             fontSize: 14,
      //             fontFamily: 'PingFang TC',
      //             fontWeight: FontWeight.w400,
      //           ),
      //         ),
      //         onTap: () {},
      //       ),
      //
      //     ],
      //   ),
      // )
      //     : null,
      // appBar: contentIndex == 0
      //     ? AppBar(
      //   backgroundColor: Colors.white,
      //   scrolledUnderElevation: 0,
      //   elevation: 0,
      //   title: Text(
      //     'pop circle文字logo',
      //     style: TextStyle(
      //       color: const Color(0xFF333333),
      //       fontSize: 16,
      //       fontFamily: 'PingFang TC',
      //       fontWeight: FontWeight.w400,
      //     ),
      //   ),
      //   centerTitle: false,
      // )
      //     : null,
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
                'assets/icons/index_frame/home.svg',
                '首頁',
              ),
              _buildBottomNavigationBarItem(
                1,
                'assets/icons/index_frame/search.svg',
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
                'assets/icons/index_frame/notification.svg',
                '通知',
              ),
              _buildBottomNavigationBarItem(
                3,
                'assets/icons/index_frame/user.svg',
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
        return PersonalPage();
      default:
        return const Center(child: Text("尚未開放"));
    }
  }
}
