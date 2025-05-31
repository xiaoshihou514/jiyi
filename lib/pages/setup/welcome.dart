import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/setup/master_key.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/pages/setup/storage.dart';
import 'package:jiyi/utils/smooth_router.dart';

const delay_1 = Duration(milliseconds: 100);
const duration_1 = Duration(seconds: 1);

final delay_2_1 = delay_1 + duration_1 + Duration(milliseconds: 100);
final duration_2_1 = Duration(milliseconds: 500);
final delay_2_2 = delay_2_1 + duration_2_1;
final duration_2_2 = Duration(milliseconds: 500);

final delay_3 = delay_2_2 + duration_2_2 + Duration(milliseconds: 500);
const duration_3 = Duration(seconds: 1);

final delay_4_1 = delay_3 + duration_3 + Duration(milliseconds: 100);
const duration_4_1 = Duration(seconds: 1);
final delay_4_2 = delay_4_1 + duration_4_1;
const duration_4_2 = Duration(milliseconds: 500);

final delayLightup = delay_4_2 + duration_4_2 + Duration(seconds: 1);
const durationLightup = Duration(seconds: 1);

class WelcomePage extends StatefulWidget {
  final String? _masterKey;
  final String? _storagePath;
  const WelcomePage(this._masterKey, this._storagePath, {super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  _WelcomePageState();

  @override
  Widget build(BuildContext context) {
    Future.delayed(delayLightup + durationLightup, () {
      if (context.mounted) {
        if (widget._masterKey == null) {
          Navigator.pushReplacement(
            context,
            SmoothRouter.builder(MasterKeyPage(widget._storagePath)),
          );
        } else if (widget._storagePath == null) {
          Navigator.pushReplacement(
            context,
            SmoothRouter.builder(StoragePage(widget._masterKey!)),
          );
        }
      } else {
        // Uh, idk
      }
    });

    ScreenUtil.init(context);
    final l = AppLocalizations.of(context)!;
    final double fontSize = 15.em;
    final double iconSize = 15.em;

    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: fontSize,
        fontFamily: "851手写杂书体",
        decoration: TextDecoration.none,
        color: DefaultColors.fg,
      ),
      child: Container(
        color: DefaultColors.bg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.graphic_eq,
                  size: iconSize,
                  color: DefaultColors.info,
                ).animate().fadeIn(delay: delay_1, duration: duration_1),

                // "welcome_1": "你所记录的",
                Text.rich(
                  TextSpan(text: l.welcome_1),
                ).animate().fadeIn(delay: delay_1, duration: duration_1),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                      Icons.photo_library,
                      size: iconSize,
                      color: DefaultColors.func,
                    )
                    .animate()
                    .fadeIn(delay: delay_2_2, duration: duration_2_2)
                    .tint(
                      color: DefaultColors.func,
                      delay: delay_2_2,
                      duration: duration_2_2,
                    ),

                // "welcome_2_1": "就是",
                Text.rich(
                  TextSpan(text: l.welcome_2_1),
                ).animate().fadeIn(delay: delay_2_1, duration: duration_2_1),

                // "welcome_2_2": "你的回忆",
                Text.rich(TextSpan(text: l.welcome_2_2))
                    .animate()
                    .fadeIn(delay: delay_2_2, duration: duration_2_2)
                    .tint(color: DefaultColors.special),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_person_rounded,
                  size: iconSize,
                  color: DefaultColors.keyword,
                ).animate().fadeIn(delay: delay_3, duration: duration_3),

                // "welcome_3": "让心事沉入琥珀",
                Text.rich(
                  TextSpan(text: l.welcome_3),
                ).animate().fadeIn(delay: delay_3, duration: duration_3),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "welcome_4_1": "封存",
                Text.rich(
                  TextSpan(text: l.welcome_4_1),
                ).animate().fadeIn(delay: delay_4_1, duration: duration_4_1),
                // "welcome_4_2": "此刻"
                Text.rich(
                  TextSpan(text: l.welcome_4_2),
                ).animate().fadeIn(delay: delay_4_2, duration: duration_4_2),
              ],
            ),
          ],
        ),
      ).animate().fadeOut(delay: delayLightup, duration: durationLightup),
    );
  }
}
