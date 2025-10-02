import 'package:flutter/material.dart';

class LabeledProgressBar extends StatelessWidget {
  // final String label;
  final double? percent;    // 0~1，外部直接控制
  final int? current;       // 若沒有 percent，可給 current/total
  final int? total;

  final double barHeight;
  final Color trackColor;
  final List<Color> barGradient;

  const LabeledProgressBar({
    super.key,
    // required this.label,
    this.percent,
    this.current,
    this.total,
    this.barHeight = 8,
    this.trackColor = const Color(0xFFE7E7E7),
    this.barGradient = const [Color(0xFF52A7F8), Color(0xFF2D8CF0)],
  }) : assert(
  percent != null || (current != null && total != null),
  '請提供 percent 或 current/total 其一',
  );

  double get _p {
    if (percent != null) return percent!.clamp(0, 1);
    if (total == 0) return 0;
    return ((current ?? 0) / (total ?? 1)).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    final percentText = '${(p * 100).round()}%';
    final subtitle = (current != null && total != null) ? '$current/$total' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Expanded(
        //       child: Text('$label  $subtitle',
        //           style: const TextStyle(fontSize: 14, color: Colors.black87)),
        //     ),
        //     Text(percentText, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        //   ],
        // ),
        // const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight / 2),
          child: Stack(
            children: [
              Container(height: barHeight, color: trackColor),
              FractionallySizedBox(
                widthFactor: p,
                alignment: Alignment.centerLeft,
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: barGradient),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
