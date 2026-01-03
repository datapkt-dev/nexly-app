import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback onPressed;

  const SubmitButton({super.key, required this.buttonName, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C538A),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(buttonName, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
