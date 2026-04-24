import 'package:flutter/material.dart';

class ReplyIndicator extends StatelessWidget {
  final String label;
  final VoidCallback onCancel;

  const ReplyIndicator({
    super.key,
    required this.label,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
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