import 'package:flutter/material.dart';

Color getStatusColor(String emoji) {
  // 根据emoji生成一致的颜色
  final hash = emoji.codeUnits.fold(0, (prev, code) => prev + code);
  final hue = hash % 360;
  return HSLColor.fromAHSL(1.0, hue.toDouble(), 0.7, 0.6).toColor();
}
