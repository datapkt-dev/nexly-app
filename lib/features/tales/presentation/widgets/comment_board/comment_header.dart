import 'package:flutter/material.dart';

class CommentHeader extends StatelessWidget {
  final String name;
  final bool isLiked;
  final VoidCallback onLike;

  const CommentHeader({
    super.key,
    required this.name,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 14,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onLike,
          child: Icon(
            Icons.favorite,
            size: 20,
            color: isLiked ? Colors.red : const Color(0xFFD9D9D9),
          ),
        ),
      ],
    );
  }
}