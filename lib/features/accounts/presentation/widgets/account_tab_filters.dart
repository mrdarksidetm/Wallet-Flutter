import 'package:flutter/material.dart';

class AccountTabFilters extends StatelessWidget {
  final List<String> months = ['Sep 25', 'Aug 25', 'Jul 25', 'Mar 25', 'Feb 25'];

  AccountTabFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: months.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFFE5A48F).withOpacity(0.8) // Match the primary peach colour for active
                  : const Color(0xFF5A583B), // Match the dark olive green
              borderRadius: BorderRadius.circular(8), // Slight rounding, not full pills
            ),
            child: Center(
              child: Text(
                months[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : const Color.fromARGB(255, 230, 230, 190),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
