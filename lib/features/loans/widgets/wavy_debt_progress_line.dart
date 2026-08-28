import 'dart:math';
import 'package:flutter/material.dart';

/// Animated Harmonic Wavy Line Visualizer for Debt / Loan Progress
/// Renders a dynamic sine wave split into "Paid Back" vs "Remaining to Pay".
class WavyDebtProgressLine extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Color paidColor;
  final Color remainingColor;
  final double height;
  final double strokeWidth;

  const WavyDebtProgressLine({
    super.key,
    required this.progress,
    this.paidColor = const Color(0xFF10B981),
    this.remainingColor = const Color(0xFFEF4444),
    this.height = 36.0,
    this.strokeWidth = 3.5,
  });

  @override
  State<WavyDebtProgressLine> createState() => _WavyDebtProgressLineState();
}

class _WavyDebtProgressLineState extends State<WavyDebtProgressLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);
    final percentInt = (clampedProgress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: widget.paidColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$percentInt% Paid',
                style: TextStyle(
                  color: widget.paidColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            Text(
              '${100 - percentInt}% Remaining',
              style: TextStyle(
                color: widget.remainingColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: _WavyProgressPainter(
                progress: clampedProgress,
                phase: _controller.value * 2 * pi,
                paidColor: widget.paidColor,
                remainingColor: widget.remainingColor,
                strokeWidth: widget.strokeWidth,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WavyProgressPainter extends CustomPainter {
  final double progress;
  final double phase;
  final Color paidColor;
  final Color remainingColor;
  final double strokeWidth;

  _WavyProgressPainter({
    required this.progress,
    required this.phase,
    required this.paidColor,
    required this.remainingColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final midY = height / 2;
    final amplitude = (height / 2) * 0.55;
    final splitX = width * progress;

    const double wavelength = 42.0; // Wave frequency

    // --- 1. Background Grid / Base Track (Subtle guide track) ---
    final trackPaint = Paint()
      ..color = remainingColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8
      ..strokeCap = StrokeCap.round;

    final baseWavePath = Path();
    for (double x = 0; x <= width; x += 2) {
      final y = midY + sin((x / wavelength * 2 * pi) + phase) * amplitude;
      if (x == 0) {
        baseWavePath.moveTo(x, y);
      } else {
        baseWavePath.lineTo(x, y);
      }
    }
    canvas.drawPath(baseWavePath, trackPaint);

    // --- 2. Paid Wave Path (0 -> splitX) ---
    if (progress > 0) {
      final paidPath = Path();
      for (double x = 0; x <= splitX; x += 2) {
        final y = midY + sin((x / wavelength * 2 * pi) + phase) * amplitude;
        if (x == 0) {
          paidPath.moveTo(x, y);
        } else {
          paidPath.lineTo(x, y);
        }
      }

      // Fill area under paid wave
      final fillPath = Path.from(paidPath)
        ..lineTo(splitX, height)
        ..lineTo(0, height)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            paidColor.withValues(alpha: 0.25),
            paidColor.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, width, height))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // Stroke for Paid Wave
      final paidPaint = Paint()
        ..color = paidColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(paidPath, paidPaint);
    }

    // --- 3. Remaining Wave Path (splitX -> width) ---
    if (progress < 1.0) {
      final remainingPath = Path();
      bool isFirst = true;
      for (double x = splitX; x <= width; x += 2) {
        final y = midY + sin((x / wavelength * 2 * pi) + phase) * amplitude;
        if (isFirst) {
          remainingPath.moveTo(x, y);
          isFirst = false;
        } else {
          remainingPath.lineTo(x, y);
        }
      }

      final remainingPaint = Paint()
        ..color = remainingColor.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.9
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(remainingPath, remainingPaint);
    }

    // --- 4. Glowing Node Indicator at Split Point ---
    if (progress > 0.0 && progress < 1.0) {
      final nodeY = midY + sin((splitX / wavelength * 2 * pi) + phase) * amplitude;
      final nodeCenter = Offset(splitX, nodeY);

      // Outer Pulse Glow
      final glowPaint = Paint()
        ..color = paidColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodeCenter, 7.5, glowPaint);

      // Inner Core Point
      final corePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodeCenter, 4.0, corePaint);

      final borderPaint = Paint()
        ..color = paidColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(nodeCenter, 4.0, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavyProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.phase != phase ||
        oldDelegate.paidColor != paidColor ||
        oldDelegate.remainingColor != remainingColor;
  }
}
