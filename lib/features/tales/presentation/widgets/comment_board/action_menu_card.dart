import 'package:flutter/material.dart';

class ActionMenuItem {
  final String title;
  final Color textColor;
  final VoidCallback onTap;

  ActionMenuItem({
    required this.title,
    required this.textColor,
    required this.onTap,
  });
}

class ActionMenuCard extends StatelessWidget {
  final List<ActionMenuItem> items;

  const ActionMenuCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 161, // 固定寬度，避免放在 Positioned 中因為 unbounded 寬度造成畫面卡死
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 0),
            spreadRadius: 0,
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: item.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                item.title,
                style: TextStyle(
                  color: item.textColor,
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFF0F0F0),
        ),
      ),
    );
  }
}

/// 於長按位置附近彈出 ActionMenuCard。
Future<String?> showActionMenuAt(
  BuildContext context,
  Offset globalPosition,
  List<ActionMenuItem> Function(void Function(String key) pop) itemsBuilder,
) async {
  // 先以暫定 pop 建立 items，確認非空才彈出
  final probeItems = itemsBuilder((_) {});
  if (probeItems.isEmpty) {
    debugPrint('[ActionMenu] no items to show, skip');
    return null;
  }

  final screen = MediaQuery.of(context).size;
  const double cardMinWidth = 161;
  final double cardApproxHeight = 44.0 * probeItems.length + 16;

  double left = globalPosition.dx;
  double top = globalPosition.dy;
  if (left + cardMinWidth > screen.width - 8) {
    left = screen.width - cardMinWidth - 8;
  }
  if (top + cardApproxHeight > screen.height - 8) {
    top = globalPosition.dy - cardApproxHeight;
  }
  if (left < 8) left = 8;
  if (top < 8) top = 8;

  return showGeneralDialog<String?>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'action-menu',
    barrierColor: Colors.black26,
    useRootNavigator: true,
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (ctx, __, ___) {
      final items = itemsBuilder((key) => Navigator.of(ctx).pop(key));
      return Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            child: Material(
              color: Colors.transparent,
              child: ActionMenuCard(items: items),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (ctx, anim, __, child) {
      return FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim),
          alignment: Alignment.topLeft,
          child: child,
        ),
      );
    },
  );
}
