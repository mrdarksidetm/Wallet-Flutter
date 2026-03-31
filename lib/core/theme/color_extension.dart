import 'package:flutter/material.dart';

extension StringColorExtension on String {
  Color parseHexColor() {
    try {
      var hex = replaceFirst('#', '').replaceFirst(RegExp(r'0[xX]'), '').toUpperCase();
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      if (hex.length > 8) {
        hex = hex.substring(hex.length - 8);
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
