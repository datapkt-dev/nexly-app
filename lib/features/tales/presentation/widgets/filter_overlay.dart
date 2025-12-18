import 'package:flutter/material.dart';
import 'tag_selector.dart';

class FilterOverlay extends StatelessWidget {
  final bool show;
  final List<String> tags;
  final List<bool> active;
  final VoidCallback onClose;
  final void Function(int index) onTagTap;

  const FilterOverlay({
    super.key,
    required this.show,
    required this.tags,
    required this.active,
    required this.onClose,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return const SizedBox.shrink();

    return Stack(
      children: [
        // ---------- 黑色遮罩 ----------
        GestureDetector(
          onTap: onClose,
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.black.withOpacity(0.5),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // ---------- 白色 Filter Panel ----------
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x19333333),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Header ----------
                Row(
                  children: [
                    const Text(
                      '類型',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 14,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClose,
                      child: const Icon(Icons.expand_more),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ---------- Tag Selector ----------
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    TagSelector(
                      tags: tags,
                      active: active,
                      onTap: onTagTap,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
