import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
class HomeHeader extends StatelessWidget {
  final String? userPhoto;
  final String userName;
  final String greeting;

  const HomeHeader({
    super.key,
    this.userPhoto,
    required this.userName,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Logo & Greeting
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDynamicShadowLogo(),
              const SizedBox(height: 8),
              Text(
                '$greeting, $userName',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Right Side: Settings & Profile
          Row(
            children: [
              // Settings Icon
              IconButton(
                icon: const Icon(Symbols.settings),
                onPressed: () {
                  context.push('/settings');
                },
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),

              // User Profile Avatar
              GestureDetector(
                onTap: () {
                  context.push('/edit_profile');
                },
                child: () {
                  final bool hasValidPhoto = userPhoto != null && File(userPhoto!).existsSync();
                  
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage: hasValidPhoto 
                        ? FileImage(File(userPhoto!)) 
                        : null,
                    child: !hasValidPhoto
                        ? Icon(
                            Symbols.person,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          )
                        : null,
                  );
                }(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicShadowLogo() {
    const double logoSize = 36.0;
    const String logoPath = 'assets/images/logo.svg';

    return Stack(
      children: [
        // The Shadow Layer (Blurred and Offset)
        Transform.translate(
          offset: const Offset(0, 4),
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Opacity(
              opacity: 0.4,
              child: SvgPicture.asset(
                logoPath,
                width: logoSize,
                height: logoSize,
              ),
            ),
          ),
        ),
        // The Crisp Foreground Logo
        SvgPicture.asset(
          logoPath,
          width: logoSize,
          height: logoSize,
        ),
      ],
    );
  }
}
