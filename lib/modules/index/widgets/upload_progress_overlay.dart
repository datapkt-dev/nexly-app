import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';

/// 全域發文進度條 — 放在 Index 的 body 最上方
/// 只在 isUploading == true 時顯示，3 秒動畫跑完自動收起
class UploadProgressOverlay extends ConsumerWidget {
  const UploadProgressOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadProgressProvider);

    if (!uploadState.isUploading) return const SizedBox.shrink();

    return _UploadProgressBar(
      progress: uploadState.progress,
      thumbnailPath: uploadState.thumbnailPath,
    );
  }
}

class _UploadProgressBar extends StatelessWidget {
  final double progress;
  final String? thumbnailPath;

  const _UploadProgressBar({
    required this.progress,
    this.thumbnailPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          // 縮圖
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: thumbnailPath != null && thumbnailPath!.isNotEmpty
                ? Image.file(
                    File(thumbnailPath!),
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 32,
                    height: 32,
                    color: const Color(0xFFE7E7E7),
                    child: const Icon(Icons.image, size: 18, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          // 文字與進度條
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '正在發佈貼文',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF333333),
                    fontFamily: 'PingFang TC',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                // 漸層進度條
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: double.infinity,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7E7E7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEDB60C), Color(0xFF24B7BD)],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
