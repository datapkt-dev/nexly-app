import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showSend;
  final VoidCallback onSend;

  const CommentInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.showSend,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFECF0F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                hintText: '新增留言',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        if (showSend) ...[
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF2C538A),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset('assets/icons/leave_comment.svg'),
            ),
          ),
        ],
      ],
    );
  }
}