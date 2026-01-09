import 'package:flutter/material.dart';

import '../controller/accountSetting_controller.dart';

class BlackList extends StatefulWidget {
  final blockList;
  const BlackList({super.key, this.blockList});

  @override
  State<BlackList> createState() => _BlackListState();
}

class _BlackListState extends State<BlackList> {
  final AccountSettingController accountSettingController = AccountSettingController();
  List? blockList;

  void unblock (int id) {
    accountSettingController.unBlock(id);
  }

  @override
  void initState() {
    super.initState();
    print('打開封鎖名單');
    blockList = widget.blockList;
  }

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
                  children: List.generate(blockList!.length, (index) {
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
                            children: [
                              Text(
                                '${blockList?[index]['name']}',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${blockList?[index]['name']}',
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
                            onSelected: (v) {
                              print('解除');
                              unblock(blockList?[index]['id']);
                              Navigator.pop(context, 'refresh');
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'unblock',
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
