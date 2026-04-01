import 'package:flutter/material.dart';

extension StringColorExtension on String {
  Color parseHexColor() {
    try {
      // 1. Clean the string: trim, uppercase
      String hex = trim().toUpperCase();
      
      // 2. Remove any prefix
      hex = hex.replaceAll('#', '').replaceAll('0X', '');

      // 3. Handle shorthand hex (e.g., "ABC" -> "AABBCC")
      if (hex.length == 3) {
        hex = hex.split('').map((char) => char * 2).join();
      } else if (hex.length == 4) {
        hex = hex.split('').map((char) => char * 2).join();
      }

      // 4. Ensure it has an alpha channel (AARRGGBB)
      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      // 5. If it's too long (e.g., someone accidentally passed "0xFFRRGGBB" after stripping)
      // we take the LAST 8 characters which are most likely the AARRGGBB part.
      if (hex.length > 8) {
        hex = hex.substring(hex.length - 8);
      }

      // 6. Safe parsing with tryParse
      final intValue = int.tryParse(hex, radix: 16);
      if (intValue != null) {
        return Color(intValue);
      }
      
      return Colors.blue; // Fallback
    } catch (e) {
      return Colors.blue; // Ultimate fallback
    }
  }
}
