import 'package:flutter/material.dart';
import '../../../features/tales/presentation/widgets/report.dart';
import 'share_bottom_sheet.dart';

class ActionMenuBottomSheet extends StatelessWidget {
  const ActionMenuBottomSheet({
    super.key,
    required this.rootContext,     // 父畫面 context，用來顯示下一層 sheet / SnackBar
    required this.targetId,
  });

  final BuildContext rootContext;
  final String targetId;

  static Future<void> show(
      BuildContext context, {
        required BuildContext rootContext,
        required String targetId,
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

          tile('分享', () async {
            Navigator.pop(context); // 關閉選單
            await Future.microtask(() {}); // 確保已關閉後再開下一層
            ShareBottomSheet.show(rootContext);
          }),
          tile('收藏', () {
            Navigator.pop(context); // 關閉選單
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
            final result = await ReportBottomSheet.show(
              rootContext,
              targetId: targetId,
              targetType: ReportTarget.post, // 或 ReportTarget.user 視情況
            );
            if (result != null) {
              ScaffoldMessenger.of(rootContext).showSnackBar(
                const SnackBar(content: Text('已送出檢舉')),
              );
            }
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
