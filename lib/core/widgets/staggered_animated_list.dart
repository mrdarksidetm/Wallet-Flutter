import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Phase 52: Staggered List Entrance Choreography
///
/// CRITICAL: Fluid Entrance Animations
/// When the list loads initially, items should cascade into view rather than
/// popping in instantly. Using `AnimationLimiter` ensures this stagger
/// only runs on initial load (or when new items are added), keeping scroll 
/// performance butter-smooth at 120Hz afterwards.
class StaggeredAnimatedList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const StaggeredAnimatedList({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: itemBuilder(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}
