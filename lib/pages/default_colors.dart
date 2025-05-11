import 'package:flutter/material.dart';

abstract class DefaultColors {
  static Color from(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color bg = from("#1F2224");
  static Color shade_1 = from("#323639");
  static Color shade_2 = from("#44494c");
  static Color shade_3 = from("#575c61");
  static Color shade_4 = from("#6a7175");
  static Color shade_5 = from("#7e858a");
  static Color shade_6 = from("#939a9f");

  static Color fg = from("#a8aeb4");
  static Color func = from("#c9bb7f");
  static Color special = from("#d5a37b");
  static Color error = from("#d89e98");
  static Color constant = from("#c59eb4");
  static Color type = from("#876aa8");
  static Color keyword = from("#51849e");
  static Color info = from("#42868d");
  static Color string = from("#738b58");

  static Color difftext = from("#364427");
  static Color diffadd = from("#23404f");
  static Color diffdel = from("#743f4d");
}
