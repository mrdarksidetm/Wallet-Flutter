import 'package:flutter/material.dart';

extension StringColorExtension on String {
  Color parseHexColor() {
    try {
      var hex = replaceAll('#', '').replaceFirst('0x', '').toUpperCase();
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return Colors.blue; 
    }
  }
}
