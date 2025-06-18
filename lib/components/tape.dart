import 'package:flutter/material.dart';
import 'package:jiyi/pages/default_colors.dart';

class Tape extends StatefulWidget {
  const Tape({super.key});

  @override
  State<Tape> createState() => _TapeState();
}

class _TapeState extends State<Tape> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        key: UniqueKey(),
        painter: TapePainter(),
        child: Container(),
      ),
    );
  }
}

class TapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = DefaultColors.shade_5;
    final w = size.width;
    final h = size.height;
    // main frame
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.05 * w, 0.05 * h, w * 0.9, h * 0.9),
        Radius.circular(w * 0.04),
      ),
      bg,
    );
    // lower clutches
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.92, h * 0.5, w * 0.05, h * 0.38),
        Radius.circular(w * 0.04),
      ),
      bg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.03, h * 0.5, w * 0.05, h * 0.38),
        Radius.circular(w * 0.04),
      ),
      bg,
    );
    // lower lines
    final fg = Paint()
      ..color = DefaultColors.bg
      ..strokeWidth = w / 128;
    canvas.drawLine(Offset(0.2 * w, 0.95 * h), Offset(0.25 * w, 0.8 * h), fg);
    canvas.drawLine(Offset(0.8 * w, 0.95 * h), Offset(0.75 * w, 0.8 * h), fg);
    canvas.drawLine(Offset(0.25 * w, 0.8 * h), Offset(0.75 * w, 0.8 * h), fg);
    // lower hole decorations
    canvas.drawCircle(Offset(0.27 * w, 0.91 * h), w * 0.015, fg);
    canvas.drawCircle(Offset(0.73 * w, 0.91 * h), w * 0.015, fg);
    canvas.drawCircle(Offset(0.32 * w, 0.89 * h), w * 0.02, fg);
    canvas.drawCircle(Offset(0.68 * w, 0.89 * h), w * 0.02, fg);
    // tape background
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.09 * w, 0.13 * h, w * 0.82, h * 0.62),
        Radius.circular(w * 0.03),
      ),
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
