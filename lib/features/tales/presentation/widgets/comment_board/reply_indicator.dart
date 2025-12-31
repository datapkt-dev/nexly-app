import 'package:flutter/material.dart';

class ReplyIndicator extends StatelessWidget {
  final String name;
  final VoidCallback onCancel;

  const ReplyIndicator({
    super.key,
    required this.name,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '正在回覆 $name',
          style: const TextStyle(color: Color(0xFF898989)),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onCancel,
          child: const Icon(Icons.close),
        ),
      ],
    );
  }
}