import 'dart:math';

import 'package:flutter/material.dart';

/// Shared painting utilities for the memory universe: star dust,
/// soft nebula clouds made of blurred radial blobs, glowing stars
/// and dashed constellation lines.
abstract class Nebula {
  /// Tiny deterministic background stars inside [rect].
  static void dust(
    Canvas canvas,
    Rect rect,
    int seed, {
    int count = 90,
    double alpha = 0.6,
  }) {
    final rng = Random(seed);
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final x = rect.left + rng.nextDouble() * rect.width;
      final y = rect.top + rng.nextDouble() * rect.height;
      paint.color = Colors.white.withValues(
        alpha: (0.12 + rng.nextDouble() * 0.4) * alpha,
      );
      canvas.drawCircle(Offset(x, y), 0.4 + rng.nextDouble() * 1.0, paint);
    }
  }

  /// A soft multi-layer nebula cloud. Each color becomes a large blurred
  /// radial blob scattered around [center]. Expensive — only call from
  /// static painters (shouldRepaint == false).
  static void cloud(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colors,
    int seed, {
    double squash = 0.75,
    double intensity = 1.0,
  }) {
    final rng = Random(seed);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, squash);
    for (var i = 0; i < colors.length; i++) {
      final angle = rng.nextDouble() * 2 * pi;
      final dist = radius * 0.4 * rng.nextDouble();
      final c = Offset(cos(angle) * dist, sin(angle) * dist);
      final r = radius * (0.5 + rng.nextDouble() * 0.5);
      final a = (0.10 + rng.nextDouble() * 0.08) * intensity;
      final paint = Paint()
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.4)
        ..shader = RadialGradient(
          colors: [
            colors[i].withValues(alpha: a),
            colors[i].withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, paint);
    }
    canvas.restore();
  }

  /// A glowing star.
  ///
  /// With [blurred] only the soft light base is drawn (expensive, static
  /// layers only). Otherwise the animated parts are drawn: halo, optional
  /// concentric [rings], optional cross [flare] and the bright core.
  static void glowStar(
    Canvas canvas,
    Offset p,
    double r,
    Color color,
    double tw, {
    int rings = 0,
    bool flare = false,
    bool blurred = false,
    double haloScale = 1.0,
  }) {
    if (blurred) {
      canvas.drawCircle(
        p,
        r * 4.2,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
          ..color = color.withValues(alpha: 0.35),
      );
      return;
    }
    // soft outer glow + halo, breathing with haloScale
    final haloR = r * 2.4 * haloScale;
    canvas.drawCircle(
      p,
      haloR * 2.2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: 0.20 * tw),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: p, radius: haloR * 2.2)),
    );
    canvas.drawCircle(
      p,
      haloR,
      Paint()..color = color.withValues(alpha: 0.16 * tw),
    );
    if (rings > 0) {
      final rp = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      for (var i = 1; i <= rings; i++) {
        rp.color = color.withValues(alpha: 0.22 * tw / i);
        canvas.drawCircle(p, r * (2.4 + i * 1.9), rp);
      }
    }
    if (flare) {
      final fp = Paint()
        ..color = Colors.white.withValues(alpha: 0.35 * tw)
        ..strokeWidth = r * 0.16
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawLine(p - Offset(r * 3.2, 0), p + Offset(r * 3.2, 0), fp);
      canvas.drawLine(p - Offset(0, r * 3.2), p + Offset(0, r * 3.2), fp);
    }
    canvas.drawCircle(
      p,
      r,
      Paint()
        ..color = Color.lerp(
          color,
          Colors.white,
          0.62,
        )!.withValues(alpha: 0.85 + 0.15 * tw),
    );
  }

  /// Dashed straight line from [a] to [b].
  static void dashedLine(
    Canvas canvas,
    Offset a,
    Offset b,
    Paint paint, {
    double dash = 3,
    double gap = 3,
  }) {
    final d = b - a;
    final len = d.distance;
    if (len == 0) return;
    final dir = d / len;
    var t = 0.0;
    while (t < len) {
      final t2 = min(t + dash, len);
      canvas.drawLine(a + dir * t, a + dir * t2, paint);
      t = t2 + gap;
    }
  }

  /// Dashed ellipse outline (orbit ring).
  static void dashedEllipse(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    int dashes = 72,
  }) {
    final c = rect.center;
    final rx = rect.width / 2;
    final ry = rect.height / 2;
    for (var i = 0; i < dashes; i += 2) {
      final a1 = i / dashes * 2 * pi;
      final a2 = (i + 1) / dashes * 2 * pi;
      canvas.drawLine(
        c + Offset(cos(a1) * rx, sin(a1) * ry),
        c + Offset(cos(a2) * rx, sin(a2) * ry),
        paint,
      );
    }
  }
}
