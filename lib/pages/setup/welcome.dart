import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/setup/master_key.dart';

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
const durationLightup = Duration(seconds: 2);

class WelcomePage extends StatefulWidget {
  final String? masterKey;
  final String? storagePath;
  const WelcomePage(this.masterKey, this.storagePath, {super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState(masterKey, storagePath);
}

class _WelcomePageState extends State<WelcomePage> {
  final String? masterKey;
  final String? storagePath;
  _WelcomePageState(this.masterKey, this.storagePath);

  @override
  Widget build(BuildContext context) {
    Future.delayed(delayLightup + durationLightup, () {
      if (context.mounted) {
        if (masterKey == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => MasterKeyPage()),
          );
        }
      } else {
        // Uh, idk
      }
    });

    return DefaultTextStyle.merge(
      style: TextStyle(
        fontSize: 80.0,
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
                  size: 80,
                  color: DefaultColors.info,
                ).animate().fadeIn(delay: delay_1, duration: duration_1),

                // "welcome_1": "你所记录的",
                Text.rich(
                  TextSpan(text: AppLocalizations.of(context)!.welcome_1),
                ).animate().fadeIn(delay: delay_1, duration: duration_1),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 80, color: DefaultColors.func)
                    .animate()
                    .fadeIn(delay: delay_2_2, duration: duration_2_2)
                    .tint(
                      color: DefaultColors.func,
                      delay: delay_2_2,
                      duration: duration_2_2,
                    ),

                // "welcome_2_1": "就是",
                Text.rich(
                  TextSpan(text: AppLocalizations.of(context)!.welcome_2_1),
                ).animate().fadeIn(delay: delay_2_1, duration: duration_2_1),

                // "welcome_2_2": "你的回忆",
                Text.rich(
                      TextSpan(text: AppLocalizations.of(context)!.welcome_2_2),
                    )
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
                  size: 80,
                  color: DefaultColors.keyword,
                ).animate().fadeIn(delay: delay_3, duration: duration_3),

                // "welcome_3": "让心事沉入琥珀",
                Text.rich(
                  TextSpan(text: AppLocalizations.of(context)!.welcome_3),
                ).animate().fadeIn(delay: delay_3, duration: duration_3),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "welcome_4_1": "封存",
                Text.rich(
                  TextSpan(text: AppLocalizations.of(context)!.welcome_4_1),
                ).animate().fadeIn(delay: delay_4_1, duration: duration_4_1),
                // "welcome_4_2": "此刻"
                Text.rich(
                  TextSpan(text: AppLocalizations.of(context)!.welcome_4_2),
                ).animate().fadeIn(delay: delay_4_2, duration: duration_4_2),
              ],
            ),
          ],
        ),
      ).animate().tint(
        color: DefaultColors.shade_3,
        delay: delayLightup,
        duration: durationLightup,
      ),
    );
  }
}
