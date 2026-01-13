import 'package:flutter/material.dart';
import '../../../features/tales/presentation/widgets/report.dart';
import '../../account_setting/controller/accountSetting_controller.dart';
import 'share_bottom_sheet.dart';

class ActionMenuBottomSheet extends StatelessWidget {
  const ActionMenuBottomSheet({
    super.key,
    required this.rootContext,     // 父畫面 context，用來顯示下一層 sheet / SnackBar
    required this.targetId,
    required this.onCollect,
  });

  final BuildContext rootContext;
  final int targetId;
  final VoidCallback onCollect;

  static Future<void> show(
      BuildContext context, {
        required BuildContext rootContext,
        required int targetId,
        required VoidCallback onCollect,
      }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ActionMenuBottomSheet(
        rootContext: rootContext,
        targetId: targetId,
        onCollect: onCollect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget tile(String text, VoidCallback onTap) => ListTile(
      title: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF333333),
          fontSize: 14,
          fontFamily: 'PingFang TC',
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
    );

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDADADA),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 6),

          // tile('分享', () async {
          //   Navigator.pop(context); // 關閉選單
          //   await Future.microtask(() {}); // 確保已關閉後再開下一層
          //   ShareBottomSheet.show(rootContext);
          // }),
          tile('收藏/取消收藏', () {
            Navigator.pop(context); // 關閉選單
            onCollect();
            ScaffoldMessenger.of(rootContext).showSnackBar(
              const SnackBar(
                content: Text('已收藏 Tales'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }),
          tile('檢舉', () async {
            Navigator.pop(context); // 關閉選單
            await Future.microtask(() {});
            // 開啟檢舉 bottom sheet（使用你前面做的）
            final result = await ReportBottomSheet.showAndSubmit(
              context,
              targetId: targetId,
              targetType: ReportTarget.tales,
              onSubmit: (report) async {
                final controller = AccountSettingController();
                return await controller.postReport(
                  report.targetType.name,
                  report.targetId,
                  report.reason.name,
                  // note: report.note,
                );
              },
            );
            if (result?['message'] == 'Report submitted successfully') {
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(content: Text('已送出檢舉')),
              );
            } else {
              ScaffoldMessenger.of(rootContext).showSnackBar(
                SnackBar(content: Text('${result?['message']}')),
              );
            }
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
