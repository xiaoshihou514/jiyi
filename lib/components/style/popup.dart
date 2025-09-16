import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';

extension Num on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? sh / 128
      : sw / 90;
}

abstract class Popup {
  static InputDecoration buildInputDecoration(
    String labelText,
    String? hintText,
  ) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(
        color: DefaultColors.shade_5,
        fontSize: 3.5.em,
        fontFamily: "朱雀仿宋",
      ),
      floatingLabelStyle: TextStyle(
        color: DefaultColors.func,
        fontSize: 3.5.em,
        fontFamily: "朱雀仿宋",
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.shade_4, width: 0.25.em),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.shade_4, width: 0.25.em),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.func, width: 0.5.em),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.error, width: 0.25.em),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.error, width: 0.5.em),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 3.em, vertical: 4.em),
    );
  }

  static Future<void> selectDateTime(
    BuildContext context,
    void Function(DateTime, TimeOfDay) callback,
  ) async {
    final l = AppLocalizations.of(context)!;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: l.metadata_select_date,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DefaultColors.func,
              onPrimary: DefaultColors.bg,
              surface: DefaultColors.bg,
              onSurface: DefaultColors.fg,
            ),
            dialogTheme: DialogThemeData(backgroundColor: DefaultColors.bg),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    if (context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: l.metadata_select_time,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: DefaultColors.func,
                onPrimary: DefaultColors.bg,
                surface: DefaultColors.bg,
                onSurface: DefaultColors.fg,
              ),
              dialogTheme: DialogThemeData(backgroundColor: DefaultColors.bg),
            ),
            child: child!,
          );
        },
      );

      if (time == null) return;

      callback(date, time);
    }
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
