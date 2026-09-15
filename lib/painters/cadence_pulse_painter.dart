import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/droniva_theme.dart';

class CadencePulsePainter extends CustomPainter {
  final double animationValue;
  final bool isRunning;
  final int bpm;

  CadencePulsePainter({
    required this.animationValue,
    required this.isRunning,
    required this.bpm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.42;

    // Background track ring
    final trackPaint = Paint()
      ..color = DronivaTheme.edge
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center, radius, trackPaint);

    // Dynamic wave glow
    if (isRunning) {
      final pulseRadius = radius + (sin(animationValue * 2 * pi) * 8);
      final glowPaint = Paint()
        ..color = DronivaTheme.accent.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16;
      canvas.drawCircle(center, pulseRadius, glowPaint);
    }

    // Active arc
    final sweepFraction = (bpm - 120) / (220 - 120);
    final sweepAngle = 2 * pi * sweepFraction.clamp(0.0, 1.0);

    final arcPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          DronivaTheme.accent.withValues(alpha: 0.2),
          DronivaTheme.accent,
          DronivaTheme.accentLight,
        ],
        stops: const [0.0, 0.7, 1.0],
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );

    // Oscillation tick dots along the rim
    for (int i = 0; i < 20; i++) {
      final angle = -pi / 2 + (i * 2 * pi / 20);
      final tickOffset = Offset(
        center.dx + (radius - 18) * cos(angle),
        center.dy + (radius - 18) * sin(angle),
      );
      final tickPaint = Paint()
        ..color = (i / 20 <= sweepFraction)
            ? DronivaTheme.accent
            : DronivaTheme.edge.withValues(alpha: 0.6);
      canvas.drawCircle(tickOffset, 2.5, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CadencePulsePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.isRunning != isRunning ||
        oldDelegate.bpm != bpm;
  }
}
