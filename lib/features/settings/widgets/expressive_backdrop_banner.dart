import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Animated Expressive Backdrop Banner
/// Animates every distinct part (left floral petal, right starburst, center harmonic scallop,
/// concentric radar rings, blueprint grid lines, and center card) at different speeds,
/// amplitudes, and orbital directions when [isExpressive] is active.
class ExpressiveBackdropBanner extends StatefulWidget {
  final bool isExpressive;
  final double borderRadius;

  const ExpressiveBackdropBanner({
    super.key,
    required this.isExpressive,
    this.borderRadius = 28.0,
  });

  @override
  State<ExpressiveBackdropBanner> createState() =>
      _ExpressiveBackdropBannerState();
}

class _ExpressiveBackdropBannerState extends State<ExpressiveBackdropBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    if (widget.isExpressive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ExpressiveBackdropBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpressive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isExpressive && _controller.isAnimating) {
      _controller.stop();
      _controller.animateTo(0.0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- SVG Vector Snippets for Individual Parts ---

  static const String _leftPetalSvg = '''
<svg width="150" height="150" viewBox="0 0 150 150" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M11.0873 94C4.62028 86.252 0.724409 76.2519 0.724409 65.3347C0.724409 40.7273 20.5177 20.7789 44.9341 20.7789C55.9847 20.7789 66.0884 24.8652 73.8387 31.6202C81.5709 24.8652 91.6509 20.7789 102.676 20.7789C127.035 20.7789 146.782 40.7273 146.782 65.3347C146.782 76.2519 142.895 86.252 136.443 94C142.895 101.748 146.782 111.748 146.782 122.665C146.782 147.273 127.035 167.221 102.676 167.221C91.6509 167.221 81.5709 163.135 73.8387 156.38C66.0884 163.135 55.9847 167.221 44.9341 167.221C20.5177 167.221 0.724409 147.273 0.724409 122.665C0.724409 111.748 4.62028 101.748 11.0873 94Z" fill="#7D5260"/>
</svg>
''';

  static const String _rightStarburstSvg = '''
<svg width="165" height="165" viewBox="255 12 165 165" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M336.661 14.1808C337.038 13.5062 337.227 13.1689 337.457 13.0275C337.79 12.8224 338.21 12.8224 338.543 13.0275C338.773 13.1689 338.962 13.5062 339.339 14.1808L352.306 37.3594C352.538 37.7741 352.654 37.9814 352.811 38.1076C353.038 38.2902 353.332 38.3688 353.62 38.3242C353.818 38.2934 354.023 38.1718 354.431 37.9287L377.25 24.3389C377.914 23.9433 378.246 23.7456 378.516 23.738C378.907 23.7271 379.271 23.9372 379.457 24.2814C379.585 24.5188 379.58 24.9052 379.569 25.6782L379.21 52.2349C379.203 52.71 379.2 52.9475 379.273 53.1352C379.378 53.4069 379.593 53.6217 379.865 53.7271C380.052 53.7998 380.29 53.7966 380.765 53.7902L407.322 53.4305C408.095 53.4201 408.481 53.4148 408.719 53.5431C409.063 53.7292 409.273 54.0932 409.262 54.4843C409.254 54.754 409.057 55.0861 408.661 55.7503L395.071 78.5692C394.828 78.9775 394.707 79.1816 394.676 79.3805C394.631 79.6684 394.71 79.9619 394.892 80.189C395.019 80.3458 395.226 80.4618 395.641 80.6938L418.819 93.6607C419.494 94.0381 419.831 94.2268 419.973 94.4566C420.178 94.7898 420.178 95.2101 419.973 95.5434C419.831 95.7732 419.494 95.9619 418.819 96.3393L395.641 109.306C395.226 109.538 395.019 109.654 394.892 109.811C394.71 110.038 394.631 110.332 394.676 110.62C394.707 110.818 394.828 111.023 395.071 111.431L408.661 134.25C409.057 134.914 409.254 135.246 409.262 135.516C409.273 135.907 409.063 136.271 408.719 136.457C408.481 136.585 408.095 136.58 407.322 136.569L380.765 136.21C380.29 136.203 380.052 136.2 379.865 136.273C379.593 136.378 379.378 136.593 379.273 136.865C379.2 137.052 379.203 137.29 379.21 137.765L379.569 164.322C379.58 165.095 379.585 165.481 379.457 165.719C379.271 166.063 378.907 166.273 378.516 166.262C378.246 166.254 377.914 166.057 377.25 165.661L354.431 152.071C354.023 151.828 353.818 151.707 353.62 151.676C353.332 151.631 353.038 151.71 352.811 151.892C352.654 152.019 352.538 152.226 352.306 152.641L339.339 175.819C338.962 176.494 338.773 176.831 338.543 176.973C338.21 177.178 337.79 177.178 337.457 176.973C337.227 176.831 337.038 176.494 336.661 175.819L323.694 152.641C323.462 152.226 323.346 152.019 323.189 151.892C322.962 151.71 322.668 151.631 322.38 151.676C322.182 151.707 321.977 151.828 321.569 152.071L298.75 165.661C298.086 166.057 297.754 166.254 297.484 166.262C297.093 166.273 296.729 166.063 296.543 165.719C296.415 165.481 296.42 165.095 296.431 164.322L296.79 137.765C296.797 137.29 296.8 137.052 296.727 136.865C296.622 136.593 296.407 136.378 296.135 136.273C295.948 136.2 295.71 136.203 295.235 136.21L268.678 136.569C267.905 136.58 267.519 136.585 267.281 136.457C266.937 136.271 266.727 135.907 266.738 135.516C266.746 135.246 266.943 134.914 267.339 134.25L280.929 111.431C281.172 111.023 281.293 110.818 281.324 110.62C281.369 110.332 281.29 110.038 281.108 109.811C280.981 109.654 280.774 109.538 280.359 109.306L257.181 96.3393C256.506 95.9619 256.169 95.7732 256.027 95.5434C255.822 95.2101 255.822 94.7898 256.027 94.4566C256.169 94.2268 256.506 94.0381 257.181 93.6607L280.359 80.6938C280.774 80.4618 280.981 80.3458 281.108 80.189C281.29 79.9619 281.369 79.6684 281.324 79.3805C281.293 79.1816 281.172 78.9775 280.929 78.5692L267.339 55.7503C266.943 55.0861 266.746 54.754 266.738 54.4843C266.727 54.0932 266.937 53.7292 267.281 53.5431C267.519 53.4148 267.905 53.4201 268.678 53.4305L295.235 53.7902C295.71 53.7966 295.948 53.7998 296.135 53.7271C296.407 53.6217 296.622 53.4069 296.727 53.1352C296.8 52.9475 296.797 52.71 296.79 52.2349L296.431 25.6782C296.42 24.9052 296.415 24.5188 296.543 24.2814C296.729 23.9372 297.093 23.7271 297.484 23.738C297.754 23.7456 298.086 23.9433 298.75 24.3389L321.569 37.9287C321.977 38.1718 322.182 38.2934 322.38 38.3242C322.668 38.3688 322.962 38.2902 323.189 38.1076C323.346 37.9814 323.462 37.7741 323.694 37.3594L336.661 14.1808Z" fill="#6750A4"/>
</svg>
''';

  static const String _centerScallopSvg = '''
<svg width="165" height="165" viewBox="124 13 165 165" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M184.335 25.8921C186.121 24.3197 187.014 23.5335 187.836 22.8977C199.713 13.7008 216.287 13.7008 228.164 22.8977C228.986 23.5335 229.879 24.3197 231.665 25.8921C232.263 26.4186 232.562 26.6818 232.862 26.9336C237.068 30.4624 242.085 32.8842 247.46 33.9797C247.844 34.0579 248.236 34.1281 249.019 34.2685C251.359 34.6878 252.529 34.8974 253.537 35.1445C268.117 38.7173 278.451 51.7054 278.682 66.7466C278.698 67.7865 278.642 68.9765 278.529 71.3566C278.491 72.1535 278.472 72.5519 278.463 72.9441C278.332 78.4399 279.572 83.8816 282.068 88.7765C282.246 89.1258 282.436 89.4766 282.815 90.1781C283.947 92.2734 284.513 93.321 284.949 94.2649C291.252 107.917 287.564 124.113 275.975 133.672C275.173 134.333 274.21 135.031 272.283 136.426C271.638 136.893 271.315 137.127 271.004 137.364C266.635 140.689 263.163 145.053 260.901 150.061C260.74 150.418 260.584 150.785 260.274 151.52C259.345 153.713 258.881 154.81 258.416 155.74C251.696 169.191 236.763 176.399 222.081 173.278C221.066 173.062 219.921 172.742 217.631 172.102C216.864 171.888 216.481 171.781 216.101 171.685C210.784 170.334 205.216 170.334 199.899 171.685C199.519 171.781 199.136 171.888 198.369 172.102C196.079 172.742 194.934 173.062 193.919 173.278C179.237 176.399 164.304 169.191 157.584 155.74C157.119 154.81 156.655 153.713 155.726 151.52C155.416 150.785 155.26 150.418 155.099 150.061C152.837 145.053 149.365 140.689 144.996 137.364C144.685 137.127 144.362 136.893 143.717 136.426C141.79 135.031 140.827 134.333 140.025 133.672C128.436 124.113 124.748 107.917 131.051 94.2648C131.487 93.321 132.053 92.2734 133.185 90.1781C133.564 89.4766 133.754 89.1258 133.932 88.7765C136.428 83.8816 137.668 78.4399 137.537 72.9441C137.528 72.5519 137.509 72.1535 137.471 71.3566C137.358 68.9765 137.302 67.7865 137.318 66.7466C137.549 51.7054 147.883 38.7173 162.463 35.1445C163.471 34.8974 164.641 34.6878 166.981 34.2685C167.764 34.1281 168.156 34.0579 168.54 33.9797C173.915 32.8842 178.932 30.4624 183.138 26.9336C183.438 26.6818 183.737 26.4186 184.335 25.8921Z" fill="#4F378B"/>
</svg>
''';

  static const String _centerCardBadgeSvg = '''
<svg width="125" height="125" viewBox="144 32 125 125" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect x="146" y="34" width="121" height="121" rx="38" stroke="white" stroke-opacity="0.6" stroke-width="2"/>
  <path d="M250.703 114.464V120.821H164.181V114.464H250.703Z" fill="#E6E0E9" stroke="#E6E0E9" stroke-width="0.362017"/>
  <path d="M221.946 73.0573C224.652 70.7287 228.654 70.7288 231.359 73.0573C231.994 73.6037 232.788 73.9352 233.624 74.0026C237.179 74.2892 239.982 77.1643 240.261 80.6892C240.328 81.538 240.662 82.3583 241.205 83.0017C243.508 85.7306 243.508 89.7278 241.205 92.4567C240.662 93.1001 240.328 93.9204 240.261 94.7692C239.982 98.2941 237.179 101.169 233.624 101.456C232.788 101.523 231.994 101.855 231.359 102.401C228.654 104.73 224.652 104.73 221.946 102.401C221.311 101.855 220.518 101.523 219.682 101.456C216.127 101.169 213.324 98.294 213.046 94.7692C212.979 93.9204 212.644 93.1001 212.101 92.4567C209.798 89.7279 209.798 85.7305 212.101 83.0017C212.644 82.3583 212.979 81.5381 213.046 80.6892C213.324 77.1644 216.127 74.2893 219.682 74.0026C220.518 73.9353 221.311 73.6037 221.946 73.0573Z" stroke="#E6E0E9" stroke-width="3.25815"/>
  <rect x="161.747" y="64.9033" width="89.8432" height="66.4497" rx="13.9376" stroke="#E6E0E9" stroke-width="4.70621"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 412 / 190,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scaleFactor = constraints.maxWidth / 412.0;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value * 2 * pi;

                // --- 1. Left Petal Flower Transform (Orbital floating + tilt) ---
                final leftDx = widget.isExpressive ? sin(t * 0.7) * 10 : 0.0;
                final leftDy = widget.isExpressive ? cos(t * 0.5) * 7 : 0.0;
                final leftRotate = widget.isExpressive ? sin(t * 0.35) * 0.18 : 0.0;
                final leftScale = widget.isExpressive ? 1.0 + sin(t * 0.8) * 0.04 : 1.0;

                // --- 2. Right Starburst Transform (Opposing drift + continuous spin) ---
                final rightDx = widget.isExpressive ? -cos(t * 0.6) * 9 : 0.0;
                final rightDy = widget.isExpressive ? sin(t * 0.8) * 8 : 0.0;
                final rightRotate = widget.isExpressive ? -t * 0.35 : 0.0;
                final rightScale = widget.isExpressive ? 1.0 + cos(t * 0.7) * 0.04 : 1.0;

                // --- 3. Center Harmonic Scallop (Breathing harmonic wave) ---
                final scallopRotate = widget.isExpressive ? sin(t * 0.45) * 0.12 : 0.0;
                final scallopScale = widget.isExpressive ? 1.0 + sin(t * 1.1) * 0.03 : 1.0;

                // --- 4. Blueprint Radar Circles (Radial pulsating expansion) ---
                final radarExpansion = widget.isExpressive ? sin(t * 0.9) * 3.5 : 0.0;

                // --- 5. Center Card Badge (Spring levitation + gentle float) ---
                final cardDy = widget.isExpressive ? sin(t * 1.4) * 5.0 : 0.0;
                final cardRotate = widget.isExpressive ? sin(t * 0.9) * 0.03 : 0.0;

                return Transform.scale(
                  scale: scaleFactor,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 412,
                    height: 190,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // --- Base Blueprint Grid & Radar Lines Layer ---
                        CustomPaint(
                          size: const Size(412, 190),
                          painter: _BannerGridPainter(
                            radarExpansion: radarExpansion,
                            lineAlpha: 0.28,
                          ),
                        ),

                        // --- 1. Left 4-Leaf Petal Emblem (Speed 1, Clockwise tilt) ---
                        Positioned(
                          left: 0 + leftDx,
                          top: 20 + leftDy,
                          child: Transform.rotate(
                            angle: leftRotate,
                            child: Transform.scale(
                              scale: leftScale,
                              child: SvgPicture.string(
                                _leftPetalSvg,
                                width: 147,
                                height: 147,
                              ),
                            ),
                          ),
                        ),

                        // --- 2. Right 8-Point Starburst (Speed 2, Counter spin) ---
                        Positioned(
                          left: 255 + rightDx,
                          top: 12 + rightDy,
                          child: Transform.rotate(
                            angle: rightRotate,
                            alignment: Alignment.center,
                            child: Transform.scale(
                              scale: rightScale,
                              child: SvgPicture.string(
                                _rightStarburstSvg,
                                width: 165,
                                height: 165,
                              ),
                            ),
                          ),
                        ),

                        // --- 3. Center Harmonic Scallop Medallion (Speed 3, Harmonic wave) ---
                        Positioned(
                          left: 124,
                          top: 13,
                          child: Transform.rotate(
                            angle: scallopRotate,
                            alignment: Alignment.center,
                            child: Transform.scale(
                              scale: scallopScale,
                              child: SvgPicture.string(
                                _centerScallopSvg,
                                width: 165,
                                height: 165,
                              ),
                            ),
                          ),
                        ),

                        // --- 4. Center Squircle Card Badge & Currency (Speed 4, Floating levitation) ---
                        Positioned(
                          left: 144,
                          top: 32 + cardDy,
                          child: Transform.rotate(
                            angle: cardRotate,
                            alignment: Alignment.center,
                            child: SvgPicture.string(
                              _centerCardBadgeSvg,
                              width: 125,
                              height: 125,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Custom painter for blueprint grid lines and expanding radar circles
class _BannerGridPainter extends CustomPainter {
  final double radarExpansion;
  final double lineAlpha;

  _BannerGridPainter({
    required this.radarExpansion,
    required this.lineAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: lineAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Horizontal Grid Lines
    final horizontalY = [
      20.5, 31.5, 43.5, 54.5, 65.5, 77.5, 88.5, 100.5, 111.5, 123.5, 134.5, 146.5, 157.5, 168.5
    ];
    for (var y in horizontalY) {
      canvas.drawLine(Offset(35, y), Offset(385, y), linePaint);
    }

    // Vertical Grid Lines
    final verticalX = [
      34.5, 45.5, 56.5, 67.5, 78.5, 89.5, 100.5, 111.5, 122.5, 133.5, 144.5,
      155.5, 166.5, 177.5, 188.5, 199.5, 210.5, 221.5, 232.5, 243.5, 254.5,
      265.5, 276.5, 287.5, 298.5, 309.5, 320.5, 331.5, 342.5, 353.5, 364.5, 375.5
    ];
    for (var x in verticalX) {
      canvas.drawLine(Offset(x, 14), Offset(x, 175), linePaint);
    }

    // Concentric Radar Circles with dynamic animated expansion
    const center = Offset(206, 94);
    final radii = [29.0, 46.0, 66.0, 86.0, 117.0, 143.0, 166.0];

    for (int i = 0; i < radii.length; i++) {
      final r = radii[i] + (radarExpansion * (1.0 + (i * 0.15)));
      if (r > 0) {
        canvas.drawCircle(center, r, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BannerGridPainter oldDelegate) {
    return oldDelegate.radarExpansion != radarExpansion ||
        oldDelegate.lineAlpha != lineAlpha;
  }
}
