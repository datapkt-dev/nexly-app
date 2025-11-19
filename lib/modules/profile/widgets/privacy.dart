import 'package:flutter/material.dart';
import 'black_list.dart';

class Privacy extends StatefulWidget {
  final dataPass;
  const Privacy({super.key, this.dataPass});

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  bool tales = false;
  bool cooperate = false;
  bool collection = false;

  @override
  void initState() {
    super.initState();
    print(widget.dataPass);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDADADA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 標題列
          Center(
            child: const Text(
              '隱私設定',
              style: TextStyle(
                color: Color(0xFF333333),
                fontSize: 18,
                fontFamily: 'PingFang TC',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 隱私設定
          Row(
            children: [
              const Text(
                'Tales',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                ),
              ),
              const Spacer(),
              Switch(
                value: tales,
                activeColor: const Color(0xFFE9416C),
                onChanged: (val) => setState(() => tales = val),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '協作',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                ),
              ),
              const Spacer(),
              Switch(
                value: cooperate,
                activeColor: const Color(0xFFE9416C),
                onChanged: (val) => setState(() => cooperate = val),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '收藏活動',
                style: TextStyle(
                  color: Color(0xFF333333),
                  fontSize: 14,
                  fontFamily: 'PingFang TC',
                ),
              ),
              const Spacer(),
              Switch(
                value: collection,
                activeColor: const Color(0xFFE9416C),
                onChanged: (val) => setState(() => collection = val),
              ),
            ],
          ),
          SizedBox(height: 13,),
          InkWell(
            child: Row(
              children: [
                const Text(
                  '封鎖名單',
                  style: TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14,
                    fontFamily: 'PingFang TC',
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
              ],
            ),
            onTap: () async {
              Navigator.pop(context); // 關閉選單
              await Future.microtask(() {}); // 確保已關閉後再開下一層
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => BlackList(blockList: widget.dataPass,),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
