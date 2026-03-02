import 'package:flutter/material.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/anno.dart';

@Claude()
class Tape extends StatelessWidget {
  const Tape({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(painter: TapePainter()),
    );
  }
}

class TapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyRect = Rect.fromLTWH(0.04 * w, 0.03 * h, w * 0.92, h * 0.94);
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      Radius.circular(w * 0.05),
    );

    // ── Drop shadow (physical depth illusion) ─────────────────────────────────
    canvas.drawShadow(Path()..addRRect(bodyRRect), Colors.black, 8, true);

    // ── Main body – strong diagonal gradient, top-left bright → bottom-right dark
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DefaultColors.shade_6, DefaultColors.shade_2],
          stops: const [0.0, 1.0],
        ).createShader(bodyRect),
    );

    // Outer edge – dark line grounds the shape
    canvas.drawRRect(
      bodyRRect,
      Paint()
        ..color = DefaultColors.shade_1
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.008,
    );

    // ── Bevel: top & left edges catch the light ───────────────────────────────
    final hlPaint = Paint()
      ..color = DefaultColors.fg.withValues(alpha: 0.25)
      ..strokeWidth = w * 0.011
      ..strokeCap = StrokeCap.round;
    // top edge
    canvas.drawLine(
      Offset(0.04 * w + w * 0.055, 0.03 * h + h * 0.017),
      Offset(0.96 * w - w * 0.055, 0.03 * h + h * 0.017),
      hlPaint,
    );
    // left edge
    canvas.drawLine(
      Offset(0.04 * w + w * 0.018, 0.03 * h + h * 0.055),
      Offset(0.04 * w + w * 0.018, 0.97 * h - h * 0.055),
      hlPaint,
    );

    // ── Bevel: bottom & right edges in shadow ─────────────────────────────────
    final shadowEdge = Paint()
      ..color = DefaultColors.shade_1.withValues(alpha: 0.75)
      ..strokeWidth = w * 0.011
      ..strokeCap = StrokeCap.round;
    // bottom edge
    canvas.drawLine(
      Offset(0.04 * w + w * 0.055, 0.97 * h - h * 0.017),
      Offset(0.96 * w - w * 0.055, 0.97 * h - h * 0.017),
      shadowEdge,
    );
    // right edge
    canvas.drawLine(
      Offset(0.96 * w - w * 0.018, 0.03 * h + h * 0.055),
      Offset(0.96 * w - w * 0.018, 0.97 * h - h * 0.055),
      shadowEdge,
    );

    // ── Side clutch tabs ───────────────────────────────────────────────────────
    final clutchShader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [DefaultColors.shade_4, DefaultColors.shade_1],
    ).createShader(Rect.fromLTWH(0, h * 0.5, w, h * 0.42));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.924, h * 0.50, w * 0.054, h * 0.38),
        Radius.circular(w * 0.04),
      ),
      Paint()..shader = clutchShader,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.022, h * 0.50, w * 0.054, h * 0.38),
        Radius.circular(w * 0.04),
      ),
      Paint()..shader = clutchShader,
    );

    // ── Label recess ──────────────────────────────────────────────────────────
    // Simulate a sunken label area: darker bottom/right inner shadow, lighter top/left
    final labelRect = Rect.fromLTWH(0.10 * w, 0.065 * h, w * 0.80, h * 0.365);
    final labelRRect = RRect.fromRectAndRadius(
      labelRect,
      Radius.circular(w * 0.02),
    );
    canvas.drawRRect(
      labelRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DefaultColors.shade_3, DefaultColors.shade_2],
        ).createShader(labelRect),
    );
    // Inner-shadow: dark top-left stroke to look sunken
    canvas.drawRRect(
      labelRRect,
      Paint()
        ..color = DefaultColors.shade_1
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.007,
    );
    // Small inner highlight on bottom/right edge = reverse bevel = sunken illusion
    final labelInnerHL = Paint()
      ..color = DefaultColors.shade_5.withValues(alpha: 0.4)
      ..strokeWidth = w * 0.005
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final lbInner = RRect.fromRectAndRadius(
      labelRect.deflate(w * 0.006),
      Radius.circular(w * 0.016),
    );
    canvas.drawRRect(lbInner, labelInnerHL);

    // ── Tape window / reel backing ────────────────────────────────────────────
    final windowRect = Rect.fromLTWH(0.08 * w, 0.45 * h, w * 0.84, h * 0.46);
    final windowRRect = RRect.fromRectAndRadius(
      windowRect,
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(windowRRect, Paint()..color = DefaultColors.shade_1);
    // Deep inner stroke – recessed cavity
    canvas.drawRRect(
      windowRRect,
      Paint()
        ..color = DefaultColors.bg
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.018,
    );
    // Faint rim highlight on window
    canvas.drawRRect(
      windowRRect,
      Paint()
        ..color = DefaultColors.shade_4.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.004,
    );

    // ── Bottom guide track ─────────────────────────────────────────────────────
    final trackPaint = Paint()
      ..color = DefaultColors.bg.withValues(alpha: 0.85)
      ..strokeWidth = w * 0.007
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0.20 * w, 0.94 * h), Offset(0.25 * w, 0.82 * h), trackPaint);
    canvas.drawLine(Offset(0.80 * w, 0.94 * h), Offset(0.75 * w, 0.82 * h), trackPaint);
    canvas.drawLine(Offset(0.25 * w, 0.82 * h), Offset(0.75 * w, 0.82 * h), trackPaint);

    // Guide rollers
    canvas.drawCircle(Offset(0.27 * w, 0.905 * h), w * 0.018, Paint()..color = DefaultColors.bg);
    canvas.drawCircle(Offset(0.73 * w, 0.905 * h), w * 0.018, Paint()..color = DefaultColors.bg);
    // Roller specular dots
    canvas.drawCircle(
      Offset(0.264 * w, 0.897 * h),
      w * 0.007,
      Paint()..color = DefaultColors.shade_4,
    );
    canvas.drawCircle(
      Offset(0.726 * w, 0.897 * h),
      w * 0.007,
      Paint()..color = DefaultColors.shade_4,
    );

    // ── Corner Phillips screws (×4) ───────────────────────────────────────────
    void drawScrew(double cx, double cy) {
      // Outer circle with radial gradient for 3D spherical look
      canvas.drawCircle(
        Offset(cx, cy),
        w * 0.023,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.4, -0.4),
            colors: [DefaultColors.shade_5, DefaultColors.shade_1],
          ).createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: w * 0.023),
          ),
      );
      canvas.drawCircle(
        Offset(cx, cy),
        w * 0.023,
        Paint()
          ..color = DefaultColors.shade_1
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.004,
      );
      // Phillips cross
      final sp = Paint()
        ..color = DefaultColors.shade_1
        ..strokeWidth = w * 0.007
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(cx - w * 0.013, cy), Offset(cx + w * 0.013, cy), sp);
      canvas.drawLine(Offset(cx, cy - w * 0.013), Offset(cx, cy + w * 0.013), sp);
    }

    drawScrew(0.115 * w, 0.115 * h);
    drawScrew(0.885 * w, 0.115 * h);
    drawScrew(0.115 * w, 0.890 * h);
    drawScrew(0.885 * w, 0.890 * h);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

