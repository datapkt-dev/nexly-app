import 'package:flutter/material.dart';

class CommentAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const CommentAvatar({
    super.key,
    required this.url,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: const Color(0xFFE7E7E7),
        image: hasUrl
            ? DecorationImage(
          image: NetworkImage(url!),
          fit: BoxFit.cover,
        )
            : null,
        shape: OvalBorder(
          side: BorderSide(
            width: 2,
            color: const Color(0xFFE7E7E7),
          ),
        ),
      ),
    );
  }
}