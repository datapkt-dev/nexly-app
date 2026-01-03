import 'package:flutter/material.dart';

class PostTextFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;

  const PostTextFields({
    super.key,
    required this.titleController,
    required this.contentController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: titleController,
            maxLines: 1,
            decoration: const InputDecoration(
              hintText: '標題',
              border: InputBorder.none,
            ),
          ),
        ),

        // Content
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: contentController,
            minLines: 1,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: '描述',
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
