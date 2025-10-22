import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BlackList extends StatefulWidget {
  const BlackList({super.key});

  @override
  State<BlackList> createState() => _BlackListState();
}

class _BlackListState extends State<BlackList> {
  bool isPublic = false;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
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

            // 標題列
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '封鎖名單',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // 成員列表
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(10, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: Row(
                        children: [
                          // Container(
                          //   width: 40,
                          //   height: 40,
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     border: Border.all(color: const Color(0xFFE7E7E7)),
                          //   ),
                          //   child: SvgPicture.asset('assets/images/avatar_1.svg'),
                          // ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/ChatGPTphoto.png'),
                                fit: BoxFit.cover,
                              ),
                              shape: OvalBorder(
                                side: BorderSide(
                                  width: 2,
                                  color: const Color(0xFFE7E7E7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'jane',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'jane05171921',
                                style: TextStyle(
                                  color: Color(0xFF898989),
                                  fontSize: 12,
                                  fontFamily: 'PingFang TC',
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          PopupMenuButton(
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
                              // switch (v) {
                              // case _PostMenu.edit:
                              // // TODO: 編輯貼文
                              //   break;
                              // case _PostMenu.copyToCollab:
                              // // TODO: 複製至協作
                              //   break;
                              // case _PostMenu.delete:
                              //   final ok = await showDialog<bool>(
                              //     context: context,
                              //     builder: (_) => AlertDialog(
                              //       title: const Text('刪除貼文'),
                              //       content: const Text('確定要刪除此貼文嗎？'),
                              //       actions: [
                              //         TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
                              //         TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('確定')),
                              //       ],
                              //     ),
                              //   );
                              //   if (ok == true) {
                              //     // TODO: 呼叫刪除 API
                              //   }
                              //     break;
                              // }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                // value: _PostMenu.edit,
                                child: Text('解除封鎖'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
