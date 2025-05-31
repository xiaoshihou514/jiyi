import 'package:flutter/material.dart';
import 'package:jiyi/l10n/localizations.dart';

import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;

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
            _title(l.settings_map),
            MapSettings(l),
            _title(l.settings_reset),
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
          ],
        ),
      ),
    );
  }

  Widget _title(String title) => Text.rich(
    TextSpan(
      text: title,
      style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
    ),
  );

  Row _buildDangerSetting(String desc, String btn, void Function() action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(TextSpan(text: desc)),
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
    await ss.delete(key: ss.MASTER_KEY_KEY);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settings_reset_success)));
    }
  }

  Future<void> _resetStoragePath(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    await ss.delete(key: ss.STORAGE_PATH_KEY);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settings_reset_success)));
    }
  }
}

class MapSettings extends StatefulWidget {
  final AppLocalizations loc;
  const MapSettings(this.loc, {super.key});

  @override
  State<MapSettings> createState() => _MapSettingsState();
}

class _MapSettingsState extends State<MapSettings> {
  late final List<String> list;
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    final l = widget.loc;
    list = [l.settings_map_local, l.settings_map_osm];
    dropdownValue = list.first;
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.loc;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(TextSpan(text: l.settings_map_provider)),
            DropdownButton(
              value: dropdownValue,
              icon: Icon(Icons.arrow_drop_down, size: 5.em),
              style: TextStyle(
                color: DefaultColors.fg,
                fontSize: 5.em,
                decoration: TextDecoration.none,
                fontFamily: "朱雀仿宋",
              ),
              dropdownColor: DefaultColors.shade_3,
              underline: Container(
                height: 1.5,
                width: 1.2,
                color: DefaultColors.fg,
              ),
              onChanged: (String? value) =>
                  setState(() => dropdownValue = value!),
              items: list
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
            ),
          ],
        ),
      ],
    );
  }
}
