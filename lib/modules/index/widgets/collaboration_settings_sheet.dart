import 'package:flutter/material.dart';

class CollaborationSettingsSheet extends StatefulWidget {
  const CollaborationSettingsSheet({super.key});

  @override
  State<CollaborationSettingsSheet> createState() => _CollaborationSettingsSheetState();
}

class _CollaborationSettingsSheetState extends State<CollaborationSettingsSheet> {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                const Text(
                  '協作設定',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 18,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '完成',
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 16,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),

            // 輸入框
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFEEEEEE)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: '輸入資料夾名稱',
                  hintStyle: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 16,
                    fontFamily: 'PingFang TC',
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 隱私設定
            const Text(
              '協作隱私權限',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 14,
                fontFamily: 'PingFang TC',
              ),
            ),
            Row(
              children: [
                const Text(
                  '公開',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                  ),
                ),
                const Spacer(),
                Switch(
                  value: isPublic,
                  activeColor: const Color(0xFFE9416C),
                  onChanged: (val) => setState(() => isPublic = val),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 搜尋框
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18, color: Color(0xFFABABAB)),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '好友帳號、名稱',
                        hintStyle: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 16,
                          fontFamily: 'PingFang TC',
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text(
                                '已加入',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                ),
                              ),
                              Text(
                                '2025.01.01 加入',
                                style: TextStyle(
                                  color: Color(0xFF898989),
                                  fontSize: 12,
                                  fontFamily: 'PingFang TC',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 4),
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
                                child: Text('移除此帳號'),
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
