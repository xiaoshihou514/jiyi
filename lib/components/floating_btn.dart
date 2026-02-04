import 'package:flutter/material.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';

IconButton buildFloatingBtn(
  bool isMobile,
  Color color,
  IconData icon,
  VoidCallback cb,
) {
  return IconButton(
    onPressed: cb,
    icon: Container(
      width: isMobile ? 20.em : 10.em,
      height: isMobile ? 20.em : 10.em,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: DefaultColors.bg,
        size: isMobile ? 15.em : 7.5.em,
      ),
    ),
  );
}
