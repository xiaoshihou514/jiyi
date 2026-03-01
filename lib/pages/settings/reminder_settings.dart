import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/services/reminder.dart';

extension on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? ScreenUtil().screenHeight / 128
      : ScreenUtil().screenWidth / 96;
}

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
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
            ),
            Switch(
              value: _enabled,
              activeThumbColor: DefaultColors.keyword,
              onChanged: (value) async {
                await Reminder.setEnabled(value);
                setState(() => _enabled = value);
              },
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                l.settings_reminder_desc,
                style: TextStyle(color: DefaultColors.fg),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
