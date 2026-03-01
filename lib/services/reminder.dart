import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jiyi/services/io.dart';
import 'package:jiyi/services/secure_storage.dart' as ss;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

abstract class Reminder {
  static const _notificationId = 42;
  static const _channelId = 'jiyi_reminder';

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (!Platform.isAndroid) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
  }

  static Future<bool> isEnabled() async {
    final val = await ss.read(key: ss.REMINDER_ENABLED);
    return val == 'true';
  }

  static Future<void> setEnabled(bool enabled) async {
    await ss.write(key: ss.REMINDER_ENABLED, value: enabled.toString());
    if (enabled) {
      await schedule();
    } else {
      await cancel();
    }
  }

  static Future<void> cancel() async {
    if (!Platform.isAndroid) return;
    await _plugin.cancel(_notificationId);
  }

  /// Schedule a daily 8pm notification if no recording exists for today.
  static Future<void> schedule() async {
    if (!Platform.isAndroid) return;
    if (!await isEnabled()) return;

    // Cancel any existing scheduled notification first.
    await cancel();

    // Check if the user has already recorded something today.
    if (await _hasRecordingToday()) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 8pm
    );
    // If 8pm has already passed today, schedule for tomorrow.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _notificationId,
      _notificationTitle,
      _notificationBody,
      scheduled,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily reminder',
          channelDescription: 'Reminds you to make a recording each day',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Call this after a recording is successfully saved to cancel today's reminder.
  static Future<void> cancelIfRecordedToday() async {
    if (!Platform.isAndroid) return;
    if (!await isEnabled()) return;
    await cancel();
  }

  static Future<bool> _hasRecordingToday() async {
    final index = await IO.indexFuture;
    final now = DateTime.now();
    return index.any(
      (md) =>
          md.time.year == now.year &&
          md.time.month == now.month &&
          md.time.day == now.day,
    );
  }

  // Placeholders replaced at runtime via l10n; hardcoded here since the
  // service has no BuildContext. Keep in sync with ARB strings.
  static const _notificationTitle = '今天还没有录音';
  static const _notificationBody = '今天还没有留下任何记忆，趁着一天结束前录一段吧！';
}
