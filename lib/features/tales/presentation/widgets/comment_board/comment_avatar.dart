import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

    return ClipOval(
      child: hasUrl
          ? Image(
              image: CachedNetworkImageProvider(url!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                color: const Color(0xFFE7E7E7),
                child: Icon(Icons.person, color: Colors.grey, size: size * 0.5),
              ),
            )
          : Container(
              width: size,
              height: size,
              color: const Color(0xFFE7E7E7),
              child: Icon(Icons.person, color: Colors.grey, size: size * 0.5),
            ),
    );
  }
}