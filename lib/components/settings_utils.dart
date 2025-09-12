import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/pages/default_colors.dart';

abstract class SUtils {
  static bool get isMobile =>
      ScreenUtil().screenWidth < ScreenUtil().screenHeight;

  static Widget flex({required List<Widget> children}) => isMobile
      ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        )
      : Padding(
          padding: EdgeInsets.symmetric(vertical: 2.em),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        );

  static IconButton buildFileChooser(
    void Function() callback,
    IconData icon,
    Text text,
    Color bg,
  ) {
    return IconButton(
      onPressed: callback,
      iconSize: 6.em,
      alignment: Alignment.center,
      icon: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.em, vertical: 1.em),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 3.em,
            children: [
              Icon(icon, color: DefaultColors.bg),
              Flexible(child: text),
            ],
          ),
        ),
      ),
    );
  }
}

extension SettingsEM on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? sh / 128
      : sw / 96;
}
