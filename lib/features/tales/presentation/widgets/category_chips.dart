import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final void Function(int index) onTap;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 16),
          ...List.generate(categories.length, (index) {
            final category = categories[index];
            final bool isActive = category['is_active'] == true;

            return GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                height: 30,
                margin: EdgeInsets.only(left: index > 0 ? 10 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF2C538A)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFF2C538A),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category['name'] ?? '',
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF2C538A),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isActive ? Icons.close : Icons.add,
                      size: 16,
                      color: isActive
                          ? Colors.white
                          : const Color(0xFF2C538A),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
