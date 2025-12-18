import 'package:flutter/material.dart';

class TagSelector extends StatelessWidget {
  final List<String> tags;
  final List<bool> active;
  final void Function(int index) onTap;
  final bool scrollable;

  const TagSelector({
    super.key,
    required this.tags,
    required this.active,
    required this.onTap,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: List.generate(tags.length, (index) {
        final isActive = active[index];

        return GestureDetector(
          onTap: () => onTap(index),
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: ShapeDecoration(
              color: isActive ? const Color(0xFF2C538A) : Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: const Color(0xFF2C538A),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              tags[index],
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF2C538A),
                fontSize: 14,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }),
    );

    // 可選：橫向滾動 / 非滾動（給 overlay 用）
    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: content,
      );
    }

    return content;
  }
}
