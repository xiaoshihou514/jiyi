import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/components/zdpp_settings.dart';

import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/components/map_settings.dart';
import 'package:jiyi/components/asr_settings.dart';
import 'package:jiyi/components/llm_settings.dart';
import 'package:jiyi/utils/io.dart';

extension on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? sh / 128
      : sw / 96;
}

bool isMobile = ScreenUtil().screenWidth < ScreenUtil().screenHeight;
Widget _flex({required List<Widget> children}) => isMobile
    ? Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      )
    : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      );

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return DefaultTextStyle.merge(
      style: TextStyle(
        decoration: TextDecoration.none,
        color: DefaultColors.fg,
        fontFamily: "朱雀仿宋",
        fontSize: 5.em,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8.em),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 3.em,
          children: [
            MapSettings(l),
            ASRSettings(l),
            ZdppSettings(l),
            LLMSettings(l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.settings_reset,
                  style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
                ),
                Container(),
              ],
            ),
            _buildDangerSetting(
              l.settings_reset_mk_desc,
              l.settings_reset_mk,
              () => _resetMasterKey(context),
            ),
            _buildDangerSetting(
              l.settings_reset_spath_desc,
              l.settings_reset_spath,
              () => _resetStoragePath(context),
            ),
            _buildDangerSetting(
              l.settings_reset_index_desc,
              l.settings_reset_index,
              () => _resetIndex(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerSetting(String desc, String btn, void Function() action) {
    return _flex(
      children: [
        Text(desc),
        TextButton(
          onPressed: action,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? DefaultColors.bg
                  : DefaultColors.error,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: DefaultColors.error),
              ),
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? DefaultColors.error
                  : DefaultColors.bg,
            ),
            textStyle: WidgetStateProperty.all(
              TextStyle(
                decoration: TextDecoration.none,
                fontFamily: "朱雀仿宋",
                fontSize: 5.em,
              ),
            ),
          ),
          child: Padding(padding: EdgeInsets.all(1.em), child: Text(btn)),
        ),
      ],
    );
  }

  Future<void> _resetMasterKey(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    await ss.delete(key: ss.MASTER_KEY);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settings_reset_success)));
    }
  }

  Future<void> _resetStoragePath(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    await ss.delete(key: ss.STORAGE_PATH);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settings_reset_success)));
    }
  }

  Future<void> _resetIndex(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    await IO.rebuild();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settings_reset_success)));
    }
  }
}
