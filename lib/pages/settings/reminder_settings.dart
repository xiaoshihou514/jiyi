import 'package:flutter/material.dart';
import 'package:jiyi/components/style/settings.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/services/reminder.dart';
import 'package:jiyi/utils/anno.dart';

@Claude()
class ReminderSettings extends StatefulWidget {
  final AppLocalizations loc;
  const ReminderSettings(this.loc, {super.key});

  @override
  State<ReminderSettings> createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    Reminder.isEnabled().then((v) => setState(() => _enabled = v));
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.loc;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.settings_reminder,
              style: TextStyle(
                fontSize: 8.em,
                fontWeight: FontWeight.bold,
                fontFamily: "朱雀仿宋",
              ),
            ),
          ],
        ),
        Settings.flex(
          children: [
            Text(l.settings_reminder_desc, style: TextStyle(fontFamily: "朱雀仿宋")),
            Settings.settingSwitch(
              value: _enabled,
              onChanged: (value) async {
                await Reminder.setEnabled(value);
                setState(() => _enabled = value);
              },
            ),
          ],
        ),
      ],
    );
  }
}
