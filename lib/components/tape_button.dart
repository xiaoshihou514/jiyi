import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/anno.dart';

extension _EM on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? ScreenUtil().screenHeight / 128
      : ScreenUtil().screenWidth / 96;
}

/// A square extruded 3D push button matching the cassette-tape aesthetic.
///
/// Draws a button cap as a raised rectangular prism sitting on a panel:
/// - Four trapezoid side faces simulate physical depth (top/left lighter, bottom/right darker).
/// - Pressing halves the extrusion depth and shifts the face down-right.
/// - A drop shadow grounds the raised button; it vanishes when pressed.
@Claude()
class TapeButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  /// Icon tint colour. Defaults to [DefaultColors.fg].
  final Color? color;

  /// Side length of the button in logical pixels. Defaults to 20.em.
  final double? size;

  const TapeButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size,
  });

  @override
  State<TapeButton> createState() => _TapeButtonState();
}

class _TapeButtonState extends State<TapeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final side = widget.size ?? 20.em;
    final disabled = widget.onPressed == null;
    final iconColor =
        disabled ? DefaultColors.shade_3 : (widget.color ?? DefaultColors.fg);

    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
      onTapUp: disabled
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onPressed!();
            },
      onTapCancel: disabled ? null : () => setState(() => _pressed = false),
      child: SizedBox(
        width: side,
        height: side,
        child: CustomPaint(
          painter: _TapeButtonPainter(pressed: _pressed, disabled: disabled),
          child: Center(
            child: Icon(widget.icon, color: iconColor, size: side * 0.42),
          ),
        ),
      ),
    );
  }
}

class _TapeButtonPainter extends CustomPainter {
  final bool pressed;
  final bool disabled;

  _TapeButtonPainter({required this.pressed, required this.disabled});

  // Build a trapezoid path for one side face of the extruded cap.
  // [outer] is the panel edge; [inner] is the cap face edge.
  Path _trap(Offset o1, Offset o2, Offset i2, Offset i1) {
    return Path()
      ..moveTo(o1.dx, o1.dy)
      ..lineTo(o2.dx, o2.dy)
      ..lineTo(i2.dx, i2.dy)
      ..lineTo(i1.dx, i1.dy)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final radius = Radius.circular(w * 0.10);

    // Bevel depth in pixels: how far the cap protrudes from the panel.
    final bevel = disabled ? 0.0 : (pressed ? w * 0.05 : w * 0.14);
    // No lateral shift — the cap sinks straight in, face stays centred.
    const shift = 0.0;

    // ── 1. Panel/mount (darkest, bg rect) ─────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, radius),
      Paint()..color = DefaultColors.bg,
    );

    // ── 2. Drop shadow under raised cap ───────────────────────────────────
    if (!disabled && !pressed) {
      final shadowRect = Rect.fromLTWH(
        bevel + 2,
        bevel + 2,
        w - bevel * 2,
        h - bevel * 2,
      );
      canvas.drawShadow(
        Path()
          ..addRRect(
              RRect.fromRectAndRadius(shadowRect, Radius.circular(w * 0.06))),
        Colors.black,
        6,
        true,
      );
    }

    // ── 3. Side faces as filled trapezoids ────────────────────────────────
    // Outer corners (panel boundary, inset slightly from widget edge).
    const p = 1.0; // panel padding
    final oTL = Offset(p, p);
    final oTR = Offset(w - p, p);
    final oBL = Offset(p, h - p);
    final oBR = Offset(w - p, h - p);

    // Inner corners (cap face boundary).
    final iTL = Offset(bevel + shift, bevel + shift);
    final iTR = Offset(w - bevel + shift, bevel + shift);
    final iBL = Offset(bevel + shift, h - bevel + shift);
    final iBR = Offset(w - bevel + shift, h - bevel + shift);

    if (bevel > 0) {
      // Top face — lightest (light from above)
      canvas.drawPath(
        _trap(oTL, oTR, iTR, iTL),
        Paint()..color = DefaultColors.shade_6,
      );
      // Left face — second lightest
      canvas.drawPath(
        _trap(oTL, iTL, iBL, oBL),
        Paint()..color = DefaultColors.shade_4,
      );
      // Right face — darker
      canvas.drawPath(
        _trap(oTR, oBR, iBR, iTR),
        Paint()..color = DefaultColors.shade_2,
      );
      // Bottom face — darkest (deepest shadow)
      canvas.drawPath(
        _trap(oBL, iBL, iBR, oBR),
        Paint()..color = DefaultColors.shade_1,
      );
    }

    // ── 4. Cap top face ───────────────────────────────────────────────────
    final faceRect = Rect.fromLTRB(iTL.dx, iTL.dy, iBR.dx, iBR.dy);
    final faceRR =
        RRect.fromRectAndRadius(faceRect, Radius.circular(w * 0.04));

    if (disabled) {
      canvas.drawRRect(
          faceRR, Paint()..color = DefaultColors.shade_1);
    } else {
      final gradColors = pressed
          ? [DefaultColors.shade_1, DefaultColors.shade_2]
          : [DefaultColors.shade_4, DefaultColors.shade_2];
      canvas.drawRRect(
        faceRR,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradColors,
          ).createShader(faceRect),
      );

      // Inner shadow rim along top and left of face (recessed edge feel).
      canvas.drawRRect(
        faceRR,
        Paint()
          ..color = DefaultColors.bg.withValues(alpha: pressed ? 0.5 : 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.025,
      );
    }
  }

  @override
  bool shouldRepaint(_TapeButtonPainter old) =>
      old.pressed != pressed || old.disabled != disabled;
}
