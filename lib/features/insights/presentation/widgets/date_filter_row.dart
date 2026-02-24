import 'package:flutter/material.dart';

class DateFilterRow extends StatelessWidget {
  final List<String> dates = ['Sep 25', 'Aug 25', 'Jul 25', 'Mar 25', 'Feb 25'];

  DateFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: dates.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
               // Match exact Colors from 011820
              color: isSelected ? const Color(0xFFFFB39D) : const Color(0xFF4C4D26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              dates[index],
              style: TextStyle(
                color: isSelected ? Colors.black : const Color.fromARGB(255, 204, 219, 137),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          );
        },
      ),
    );
  }
}
