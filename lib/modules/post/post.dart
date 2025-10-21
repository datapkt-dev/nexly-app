import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nexly_temp/modules/post/widgets/report.dart';
import 'package:nexly_temp/modules/user/user.dart';

class Post extends StatefulWidget {
  final bool myself;
  const Post({super.key, this.myself = false});

  @override
  State<Post> createState() => _PostState();
}

enum _PostMenu {edit, copyToCollab, delete, report,}

class _PostState extends State<Post> {
  bool collected = true;
  bool liked = true;
  late bool myself;

  @override
  void initState() {
    super.initState();
    myself = widget.myself;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
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
          if (!myself) ...[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.open_in_new),
            ),
          ],
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
                case _PostMenu.report:
                  final result = await ReportBottomSheet.show(
                    context,
                    targetId: 'post_123',
                    targetType: ReportTarget.post, // 或 ReportTarget.user
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              if (myself) ...[
                const PopupMenuItem(
                  value: _PostMenu.edit,
                  child: Text('編輯貼文'),
                ),
                const PopupMenuItem(
                  value: _PostMenu.copyToCollab,
                  child: Text('複製至協作'),
                ),
                const PopupMenuItem(
                  value: _PostMenu.delete,
                  child: Text(
                    '刪除貼文',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ] else ...[
                const PopupMenuItem(
                  value: _PostMenu.report,
                  child: Text('檢舉貼文'),
                ),
              ],
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
                        GestureDetector(
                          child: Text(
                            'sam9527',
                            style: TextStyle(
                              color: const Color(0xFF333333),
                              fontSize: 14,
                              fontFamily: 'PingFang TC',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const User()),
                            );
                          },
                        ),
                        Spacer(),
                        GestureDetector(
                          child: Icon(
                            Icons.bookmark,
                            color: collected ? Color(0xFFD63C95) : Color(0xFFD9D9D9),
                          ),
                          onTap: () {
                            setState(() {
                              collected = !collected;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12,),
                  Row(
                    children: [
                      GestureDetector(
                        child: Icon(
                          Icons.favorite,
                          color: liked ? Color(0xFFED4D4D) : Color(0xFFD9D9D9),
                        ),
                        onTap: () {
                          setState(() {
                            liked = !liked;
                          });
                        },
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
                      GestureDetector(
                        child: Icon(
                          Icons.chat_bubble,
                          color: Color(0xFFD9D9D9),
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,           // 解除預設高度限制
                            backgroundColor: Colors.transparent, // 讓我們自訂圓角容器
                            builder: (ctx) {
                              return FractionallySizedBox(
                                heightFactor: 0.7, // 90% 螢幕高度
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16,),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        offset: const Offset(0, -4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      // 小手把
                                      Center(
                                        child: Container(
                                          width: 36,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDADADA),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 22),

                                      // 標題列 + 關閉
                                      Center(
                                        child: Text(
                                          '留言',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF333333),
                                            fontSize: 18,
                                            fontFamily: 'PingFang TC',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8,),
                                      // 可滾動內容
                                      Expanded(
                                        child: ListView.separated(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          itemCount: 1, // 你的資料長度
                                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    // 圖片卡（給固定寬/高避免擠壓）
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: SvgPicture.asset(
                                                        'assets/images/avatar.svg',
                                                        // fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // 右側文字塊
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Ella_1019',
                                                                style: TextStyle(
                                                                  color: const Color(0xFF333333),
                                                                  fontSize: 14,
                                                                  fontFamily: 'PingFang TC',
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              Icon(
                                                                Icons.favorite,
                                                                size: 20,
                                                                color: Color(0xFFD9D9D9),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: '＠chris1123 ',
                                                                  style: TextStyle(
                                                                    color: Color(0xFF3B5AF8),
                                                                    fontSize: 14,
                                                                    fontFamily: 'PingFang TC',
                                                                    fontWeight: FontWeight.w400,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: '來看看這個',
                                                                  style: TextStyle(
                                                                    color: const Color(0xFF333333),
                                                                    fontSize: 14,
                                                                    fontFamily: 'PingFang TC',
                                                                    fontWeight: FontWeight.w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '今天 12:00',
                                                                style: TextStyle(
                                                                  color: Color(0xFF888888),
                                                                  fontSize: 12,
                                                                  fontFamily: 'PingFang TC',
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              ),
                                                              SizedBox(width: 10,),
                                                              Text(
                                                                '回覆 1',
                                                                style: TextStyle(
                                                                  color: Color(0xFF888888),
                                                                  fontSize: 12,
                                                                  fontFamily: 'PingFang TC',
                                                                  fontWeight: FontWeight.w400,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 20,),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(width: 48,),
                                                    // 圖片卡（給固定寬/高避免擠壓）
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      child: SvgPicture.asset(
                                                        'assets/images/avatar.svg',
                                                        // fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    // 右側文字塊
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                'Chris1122',
                                                                style: TextStyle(
                                                                  color: const Color(0xFF333333),
                                                                  fontSize: 14,
                                                                  fontFamily: 'PingFang TC',
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              Icon(
                                                                Icons.favorite,
                                                                size: 20,
                                                                color: Color(0xFFD9D9D9),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            '看起來很讚欸',
                                                            style: TextStyle(
                                                              color: const Color(0xFF333333),
                                                              fontSize: 14,
                                                              fontFamily: 'PingFang TC',
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4),
                                                          Text(
                                                            '今天 12:00',
                                                            style: TextStyle(
                                                              color: Color(0xFF888888),
                                                              fontSize: 12,
                                                              fontFamily: 'PingFang TC',
                                                              fontWeight: FontWeight.w400,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),//
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),// 自訂內容（見下）
                              );
                            },
                          );
                        },
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
