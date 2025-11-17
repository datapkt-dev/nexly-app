import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key});

  final shareUrl = 'https://www.google.com/';
  final shareText = '好內容分享給你';

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SheetFrame(child: ShareBottomSheet()),
    );
  }

  Future<void> _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('連結已複製')),
    );
  }

  Future<void> _shareSystem(String url) async {
    await Share.share(url);
  }

  // Future<void> _shareToFacebook(String urlToShare) async {
  //   // 基本檢查：必須是 http/https 且有網域
  //   final uri = Uri.tryParse(urlToShare);
  //   if (uri == null || !uri.hasAuthority || !(uri.isScheme('http') || uri.isScheme('https'))) {
  //     throw 'URL 無效';
  //   }
  //
  //   // Web 版分享（你已驗證可用）
  //   final webSharer = Uri.https(
  //     'www.facebook.com',
  //     '/sharer.php',
  //     {'u': uri.toString()}, // 只放要分享的連結
  //   );
  //
  //   // 嘗試用 FB App 打開：把 web sharer 當作 facewebmodal 的 href
  //   final appDeepLink = Uri.parse(
  //     'fb://facewebmodal/f?href=${Uri.encodeComponent(webSharer.toString())}',
  //   );
  //
  //   try {
  //     if (await canLaunchUrl(appDeepLink)) {
  //       final ok = await launchUrl(appDeepLink, mode: LaunchMode.externalApplication);
  //       if (ok) return; // ✅ 成功用 FB App
  //     }
  //   } catch (_) {
  //     // 忽略，改走瀏覽器
  //   }
  //
  //   // 後備：瀏覽器 sharer.php
  //   await launchUrl(webSharer, mode: LaunchMode.externalApplication);
  // }
  Future<void> _shareToFacebook(String urlToShare) async {
    final uri = Uri.tryParse(urlToShare);
    if (uri == null || !uri.hasAuthority || !(uri.isScheme('http') || uri.isScheme('https'))) {
      throw 'URL 無效';
    }

    // https://www.facebook.com/sharer.php?u=<encoded-url>
    final shareUrl = Uri.https(
      'www.facebook.com',
      '/sharer.php',
      {'u': uri.toString()},
    );

    await launchUrl(shareUrl, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final avatars = List.generate(8, (i) => 'user_$i');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),
          const Text('分享', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          // 搜尋框
          TextField(
            decoration: InputDecoration(
              hintText: '搜尋帳號、名稱',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: const Color(0xFFF7F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 最近聯絡人
          LayoutBuilder(
            builder: (context, c) {
              final itemWidth = (c.maxWidth - 12 * (3 - 1)) / 3;

              return Wrap(
                spacing: 12,             // 水平間距
                runSpacing: 18,           // 垂直間距
                children: avatars.take(6).toList().map((name) {
                  return SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: ShapeDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/images/ChatGPTphoto.png'),
                              fit: BoxFit.cover,
                            ),
                            shape: const OvalBorder(
                              side: BorderSide(width: 2, color: Color(0xFFE7E7E7)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 12,
                            fontFamily: 'PingFang TC',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),

          Divider(height: 40,),

          // 社群目標
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ShareTarget(
                icon: Icons.copy,
                label: '複製連結',
                onTap: () => _copyLink(context, shareUrl),
              ),
              _ShareTarget(
                icon: Icons.close,
                label: 'X',
                onTap: () => _shareSystem(shareUrl), // 先走系統分享，之後要接 X 可再換
              ),
              _ShareTarget(
                icon: Icons.share,
                label: 'Threads',
                onTap: () => _shareSystem(shareUrl),
              ),
              _ShareTarget(
                icon: Icons.photo_camera,
                label: 'Instagram',
                onTap: () => _shareSystem(shareUrl),
              ),
              _ShareTarget(
                icon: Icons.facebook,
                label: 'Facebook',
                onTap: () => _shareToFacebook(shareUrl),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ShareTarget extends StatelessWidget {
  const _ShareTarget({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: ShapeDecoration(
              color: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Icon(icon),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 12,
              fontFamily: 'PingFang TC',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

/// 通用容器：白底 + 圓角 + 陰影 + 上方手把
class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, -8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDADADA),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
