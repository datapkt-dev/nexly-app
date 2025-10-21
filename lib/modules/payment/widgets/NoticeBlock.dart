import 'package:flutter/material.dart';

class NoticeBlock extends StatelessWidget {
  const NoticeBlock({
    super.key,
    this.title = '注意事項',
    required this.items,
    this.textColor = const Color(0xFF9E9E9E), // 灰色
  });

  final String title;
  final List<String> items;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    const double gap = 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: gap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ● 符號
              Text('•  ', style: TextStyle(color: textColor, fontSize: 14)),
              // 內容（可自動換行）
              Expanded(
                child: Text(
                  t,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
