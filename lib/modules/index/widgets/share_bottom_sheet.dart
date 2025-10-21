import 'package:flutter/material.dart';

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SheetFrame(child: ShareBottomSheet()),
    );
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

          // 常用聯絡人
          // SizedBox(
          //   height: 96,
          //   child: ListView.separated(
          //     scrollDirection: Axis.horizontal,
          //     itemCount: avatars.length,
          //     separatorBuilder: (_, __) => const SizedBox(width: 14),
          //     itemBuilder: (_, i) {
          //       return Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/images/avatar_${(i%4)+1}.png')),
          //           const SizedBox(height: 6),
          //           Text(
          //             avatars[i],
          //             style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //         ],
          //       );
          //     },
          //   ),
          // ),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/images/avatar_${(i%4)+1}.png')),
                    Container(
                      width: 65,
                      height: 65,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      avatars[index],
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 12,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 10,),
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/images/avatar_${(i%4)+1}.png')),
                    Container(
                      width: 65,
                      height: 65,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      avatars[index],
                      style: TextStyle(
                        color: const Color(0xFF333333),
                        fontSize: 12,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),

          Divider(height: 40,),

          // 社群目標
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ShareTarget(icon: Icons.copy, label: '複製連結'),
              _ShareTarget(icon: Icons.close, label: 'X'),
              _ShareTarget(icon: Icons.share, label: 'Threads'),
              _ShareTarget(icon: Icons.photo_camera, label: 'Instagram'),
              _ShareTarget(icon: Icons.facebook, label: 'Facebook'),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ShareTarget extends StatelessWidget {
  const _ShareTarget({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: TextStyle(
            color: const Color(0xFF333333),
            fontSize: 12,
            fontFamily: 'PingFang TC',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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
