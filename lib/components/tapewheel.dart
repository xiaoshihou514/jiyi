import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/stop_model.dart';

@Claude()
class Tapewheel extends StatefulWidget {
  final StopModel _stop;
  const Tapewheel(this._stop, {super.key});

  @override
  State<Tapewheel> createState() => _TapewheelState();
}

class _TapewheelState extends State<Tapewheel> {
  late final Timer timer;
  double turn = 0.0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 16), (Timer t) => _tick());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _tick() {
    if (!widget._stop.value && context.mounted) {
      setState(() {
        turn += 0.01;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turn,
      duration: const Duration(milliseconds: 16),
      child: CustomPaint(
        painter: TapewheelPainter(),
        child: const SizedBox.square(dimension: 100),
      ),
    );
  }
}

class TapewheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = min(w, h) / 2;

    // Outer rim with radial gradient for a domed/3D look
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.94,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.4),
          colors: [DefaultColors.shade_5, DefaultColors.shade_2],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.94)),
    );
    // Rim border
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.94,
      Paint()
        ..color = DefaultColors.shade_1
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06,
    );

    // 6 spokes radiating from hub to rim
    final spokePaint = Paint()
      ..color = DefaultColors.shade_2
      ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      canvas.drawLine(
        Offset(cx + cos(angle) * r * 0.28, cy + sin(angle) * r * 0.28),
        Offset(cx + cos(angle) * r * 0.78, cy + sin(angle) * r * 0.78),
        spokePaint,
      );
    }
    // Spoke highlight (lighter line on each spoke for 3D ridge effect)
    final spokeHL = Paint()
      ..color = DefaultColors.shade_4.withValues(alpha: 0.6)
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      canvas.drawLine(
        Offset(cx + cos(angle) * r * 0.30, cy + sin(angle) * r * 0.30),
        Offset(cx + cos(angle) * r * 0.76, cy + sin(angle) * r * 0.76),
        spokeHL,
      );
    }

    // Inner hub with radial gradient
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.30,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [DefaultColors.shade_4, DefaultColors.shade_1],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.30)),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.30,
      Paint()
        ..color = DefaultColors.shade_1
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.06,
    );

    // Center spindle hole
    canvas.drawCircle(Offset(cx, cy), r * 0.13, Paint()..color = DefaultColors.bg);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

