import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostState();
}

enum _PostMenu {edit, copyToCollab, delete,}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          '貼文',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          PopupMenuButton<_PostMenu>(
            icon: const Icon(Icons.more_vert),
            position: PopupMenuPosition.under,
            offset: const Offset(0, 8),                    // 往下偏移一點
            shape: RoundedRectangleBorder(                 // 圓角 + 邊框
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFEDEDED)),
            ),
            color: Colors.white,
            elevation: 8,
            constraints: const BoxConstraints(minWidth: 180), // 控制寬度（可調）
            onSelected: (v) async {
              switch (v) {
                case _PostMenu.edit:
                // TODO: 編輯貼文
                  break;
                case _PostMenu.copyToCollab:
                // TODO: 複製至協作
                  break;
                case _PostMenu.delete:
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('刪除貼文'),
                      content: const Text('確定要刪除此貼文嗎？'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                        TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('確定')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    // TODO: 呼叫刪除 API
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: _PostMenu.edit,          child: Text('編輯貼文')),
              const PopupMenuItem(value: _PostMenu.copyToCollab,  child: Text('複製至協作')),
              // const PopupMenuDivider(),
              const PopupMenuItem(
                value: _PostMenu.delete,
                child: Text('刪除貼文', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 513,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEFEFEF),
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/images/postImg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16,),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8,),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          // decoration: ShapeDecoration(
                          //   image: DecorationImage(
                          //     image: AssetImage('assets/images/postImg.png'),
                          //     fit: BoxFit.cover,
                          //   ),
                          //   shape: RoundedRectangleBorder(
                          //     side: BorderSide(
                          //       width: 1,
                          //       color: const Color(0xFFE7E7E7),
                          //     ),
                          //     borderRadius: BorderRadius.circular(100),
                          //   ),
                          // ),
                          // clipBehavior: Clip.antiAlias,
                          child: SvgPicture.asset(
                            'assets/images/avatar.svg',
                            // fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 7,),
                        Text(
                          'sam9527',
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 14,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.bookmark,
                          color: Color(0xFFD63C95),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12,),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Color(0xFFED4D4D),
                      ),
                      SizedBox(width: 4,),
                      Text(
                        '123',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(width: 10,),
                      Icon(
                        Icons.chat_bubble,
                        color: Color(0xFFD9D9D9),
                      ),
                      SizedBox(width: 4,),
                      Text(
                        '10',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'PingFang TC',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Text(
                    '扶老奶奶過馬路',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 16,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4,),
                  Text(
                    '首先你要先找到老奶奶\n找到老奶奶之後，你要趁拐杖不注意扶老奶奶過馬路，秘訣就是你要比他的拐杖更有用、更出色、更可靠\n記得注意安全',
                    style: TextStyle(
                      color: const Color(0xFF333333),
                      fontSize: 14,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4,),
                  Text(
                    '2025/04/12',
                    style: TextStyle(
                      color: const Color(0xFF838383),
                      fontSize: 14,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 8,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
