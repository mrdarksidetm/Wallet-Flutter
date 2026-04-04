import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/models/auxiliary_models.dart';
import '../../../core/theme/color_extension.dart';
import '../../../core/widgets/icon_picker.dart';

class PersonAvatar extends StatelessWidget {
  final Person person;
  final double radius;
  final double? fontSize;
  final VoidCallback? onTap;

  const PersonAvatar({
    super.key,
    required this.person,
    this.radius = 28,
    this.fontSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = person.color.parseHexColor();
    final avatar = person.avatar;

    Widget child;

    // 1. Check if it's a file path
    if (avatar != null && avatar.startsWith('/')) {
      final file = File(avatar);
      if (file.existsSync()) {
        child = CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
          backgroundColor: color.withValues(alpha: 0.1),
        );
      } else {
        child = _buildFallback(color);
      }
    }
    // 2. Check if it's an icon name
    else if (avatar != null && avatar.isNotEmpty && !avatar.startsWith('/')) {
      child = CircleAvatar(
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
    else {
      child = _buildFallback(color);
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: child,
      );
    }

    return child;
  }

  Widget _buildFallback(Color color) {
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
