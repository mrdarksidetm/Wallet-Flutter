import 'package:flutter/material.dart';

class CategorySegmentData {
  final Color color;
  final double percentage;
  final String name;

  CategorySegmentData({
    required this.color,
    required this.percentage,
    required this.name,
  });
}

class CategorySegmentedBar extends StatelessWidget {
  final List<CategorySegmentData> segments;

  const CategorySegmentedBar({
    super.key,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return Container(
        height: 12,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 12,
        width: double.infinity,
        child: Row(
          children: segments.map((s) {
            return Expanded(
              flex: (s.percentage * 100).round().clamp(1, 10000),
              child: Container(
                color: s.color,
                margin: const EdgeInsets.symmetric(horizontal: 0.5),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
