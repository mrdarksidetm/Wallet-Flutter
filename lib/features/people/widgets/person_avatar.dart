import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/widgets/icon_picker.dart';

class PersonAvatar extends StatelessWidget {
  final Person person;
  final double radius;
  final double? fontSize;

  const PersonAvatar({
    super.key,
    required this.person,
    this.radius = 28,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = person.color.parseHexColor();
    final avatar = person.avatar;

    // 1. Check if it's a file path
    if (avatar != null && avatar.startsWith('/')) {
      final file = File(avatar);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
          backgroundColor: color.withValues(alpha: 0.1),
        );
      }
    }

    // 2. Check if it's an icon name
    if (avatar != null && avatar.isNotEmpty && !avatar.startsWith('/')) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          AppIcons.getIcon(avatar),
          color: color,
          size: radius * 0.8,
        ),
      );
    }

    // 3. Fallback to First Letter
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.1),
      child: Text(
        person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: fontSize ?? (radius * 0.7),
        ),
      ),
    );
  }
}
