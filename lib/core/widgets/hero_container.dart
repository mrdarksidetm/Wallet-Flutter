import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// Phase 52: Container Transforms (Hero Animations)
///
/// CRITICAL: Context Preservation
/// Instead of pushing a new screen from the side, a tapped card physically
/// morphs its boundaries and corner radius to become the new screen surface.
/// This preserves the user's spatial context. The background fades out cleanly.
class HeroContainer extends StatelessWidget {
  final Widget closedWidget;
  final Widget openedWidget;
  final double closedElevation;
  final Color closedColor;

  const HeroContainer({
    Key? key,
    required this.closedWidget,
    required this.openedWidget,
    this.closedElevation = 0,
    this.closedColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      closedElevation: closedElevation,
      closedColor: closedColor,
      openElevation: 0,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      openShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      transitionDuration: const Duration(milliseconds: 500),
      closedBuilder: (context, action) {
        return InkWell(
          onTap: action,
          child: closedWidget,
        );
      },
      openBuilder: (context, action) {
        return openedWidget;
      },
    );
  }
}
