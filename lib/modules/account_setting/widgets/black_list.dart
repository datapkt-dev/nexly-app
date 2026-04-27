import 'package:flutter/material.dart';

import '../../../components/utils/display_name.dart';
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

  /// ✅ 解除封鎖：樂觀更新 → 失敗 rollback → SnackBar
  Future<void> _unblock(int index) async {
    final removed = blockList![index];
    final id = removed['id'] as int;

    // 樂觀更新：先從 UI 移除
    setState(() {
      blockList!.removeAt(index);
    });

    final result = await accountSettingController.unBlock(id);
    if (!mounted) return;

    final success = result['message'] == 'Unblocked successfully' ||
        result['code'] == 0 ||
        result['error'] == null && result['message'] != null;

    if (!success) {
      // 失敗：把資料塞回去
      setState(() {
        blockList!.insert(index, removed);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('解除封鎖失敗，請稍後再試', textAlign: TextAlign.center),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已解除封鎖', textAlign: TextAlign.center),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );

    // 全部都解除了 → 自動關閉並通知上層 refresh
    if (blockList!.isEmpty && mounted) {
      Navigator.pop(context, 'refresh');
    }
  }

  @override
  void initState() {
    super.initState();
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
                                displayAccountOrName(
                                  blockList?[index]['account'],
                                  blockList?[index]['name'],
                                ),
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontFamily: 'PingFang TC',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                (blockList?[index]['name'] ?? '').toString(),
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
                              _unblock(index);
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
