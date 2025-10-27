import 'dart:ui';
import 'package:flutter/material.dart';
import 'ringchart.dart';

// 1) 可重用：統計卡（你原本的毛玻璃 + RingChart + 右側數字）
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.title,
    required this.percent,
    required this.done,
    required this.todo,
  });

  final String title;
  final double percent;
  final int done;
  final int todo;

  @override
  Widget build(BuildContext context) {
    final total = done + todo;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.30)),
          ),
          child: Row(
            children: [
              RingChart(
                centerTitle: title,
                subtitle: '${(percent * 100).toInt()}%',
                percent: percent,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _row('已完成', done.toString()),
                    const SizedBox(height: 8),
                    _row('未完成', todo.toString()),
                    const SizedBox(height: 8),
                    _row('總計', total.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'PingFang TC',
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'PingFang TC',
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// 2) 走馬燈：左右滑動的統計卡列表（使用 PageView 內建）
class StatsCarousel extends StatefulWidget {
  const StatsCarousel({
    super.key,
    this.onIndexChanged, // 新增：回傳索引給父層
  });

  final ValueChanged<int>? onIndexChanged;

  @override
  State<StatsCarousel> createState() => _StatsCarouselState();
}

class _StatsCarouselState extends State<StatsCarousel> {
  final _page = PageController(viewportFraction: 0.88); // 露出左右邊緣
  int _index = 0;

  final items = const [
    // 你可以從後端計算 percent = done/(done+todo)
    (title: '個人', percent: 0.5, done: 10, todo: 32),
    (title: '團體', percent: 0.25, done: 8,  todo: 24),
  ];

  @override
  void initState() {
    super.initState();
    // 可選：初始化時先回報一次 0
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onIndexChanged?.call(_index);
    });
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180, // 卡片高度
          child: PageView.builder(
            controller: _page,
            itemCount: items.length,
            onPageChanged: (i) {
              setState(() => _index = i);
              widget.onIndexChanged?.call(i); // ✅ 回傳給父層
            },
            itemBuilder: (context, i) {
              final it = items[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: StatsCard(
                  title: it.title,
                  percent: it.percent,
                  done: it.done,
                  todo: it.todo,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // 指示點（不加套件的簡易版）
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: active ? 18 : 6,
              decoration: BoxDecoration(
                color: active ? Colors.white : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}
