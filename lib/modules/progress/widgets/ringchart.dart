import 'dart:math' as math;
import 'package:flutter/material.dart';

class RingChart extends StatelessWidget {
  const RingChart({
    super.key,
    required this.percent,                 // 0.0 ~ 1.0
    this.size = 160,
    this.strokeWidth = 14,
    this.color = const Color(0xFFF2B51D), // 前景色
    this.bgColor = const Color(0x33FFFFFF), // 背景環
    this.startAngleDeg = -90,              // 由上方開始
    this.centerTitle,                       // 中央文字
    this.subtitle,
    this.textStyle,                        // 文字樣式
  });

  final double percent;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color bgColor;
  final double startAngleDeg;
  final String? centerTitle;
  final String? subtitle;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              percent: percent.clamp(0, 1),
              strokeWidth: strokeWidth,
              color: color,
              bgColor: bgColor,
              startAngle: startAngleDeg * math.pi / 180,
            ),
          ),
          if (centerTitle != null) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerTitle!,
                  style: textStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (subtitle != null) Text(
                  subtitle!,
                  style: textStyle ??
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'PingFang TC',
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.percent,
    required this.strokeWidth,
    required this.color,
    required this.bgColor,
    required this.startAngle,
  });

  final double percent;
  final double strokeWidth;
  final Color color;
  final Color bgColor;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 背景環
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = bgColor;
    canvas.drawArc(rect, 0, 2 * math.pi, false, bg);

    // 前景進度
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, startAngle, 2 * math.pi * percent, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.percent != percent ||
          old.strokeWidth != strokeWidth ||
          old.color != color ||
          old.bgColor != bgColor ||
          old.startAngle != startAngle;
}
