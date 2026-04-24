import 'package:flutter/material.dart';

class CommentHeader extends StatelessWidget {
  final String name;

  const CommentHeader({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 14,
        fontFamily: 'PingFang TC',
        fontWeight: FontWeight.w500,
      ),
    );
  }
}