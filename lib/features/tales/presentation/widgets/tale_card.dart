import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TaleCard extends StatelessWidget {
  final String networkImage;
  final String tag;
  final String title;
  final bool isCollected;
  final int? heroTag;

  final VoidCallback onTap;
  final VoidCallback onCollectTap;
  final VoidCallback onMoreTap;

  const TaleCard({
    super.key,
    required this.networkImage,
    required this.tag,
    required this.title,
    required this.isCollected,
    this.heroTag,
    required this.onTap,
    required this.onCollectTap,
    required this.onMoreTap,
  });

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- 圖片區 ----------
          Stack(
            children: [
              Hero(
                tag: heroTag != null ? 'tale-image-$heroTag' : UniqueKey(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _isValidUrl(networkImage)
                      ? Image(
                          image: CachedNetworkImageProvider(networkImage),
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          filterQuality: FilterQuality.low,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: double.infinity,
                            height: 250,
                            color: const Color(0xFFE7E7E7),
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 250,
                          color: const Color(0xFFE7E7E7),
                        ),
                ),
              ),

              // ---------- 左上角標籤 ----------
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: ShapeDecoration(
                    color: Colors.black.withValues(alpha: 0.30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'PingFang TC',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // ---------- 右上角收藏 ----------
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onCollectTap,
                  child: Icon(
                    isCollected ? Icons.bookmark : Icons.bookmark_border,
                    color:
                    isCollected ? const Color(0xFFD63C95) : Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // ---------- 標題 + 更多 ----------
          Row(
            children: [
              SizedBox(width: 8,),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: onMoreTap,
              //   child: const Icon(Icons.more_vert),
              // ),
              SizedBox(width: 8,),
            ],
          ),
        ],
      ),
    );
  }
}
