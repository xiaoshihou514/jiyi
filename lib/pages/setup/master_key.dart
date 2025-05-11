import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:jiyi/em.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/main.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/setup/storage.dart';
import 'package:jiyi/smooth_router.dart';

const durationDim = Duration(seconds: 2);

class MasterKeyPage extends StatefulWidget {
  const MasterKeyPage({super.key});

  @override
  State<MasterKeyPage> createState() => _MasterKeyPage();
}

class _MasterKeyPage extends State<MasterKeyPage> {
  // text field state
  bool showMK = false;
  String masterKey = "";

  // float button ui state
  bool enteredMK = false;
  bool writing = false;

  // error handling and display
  String? error;

  Future writeMasterKey() async {
    final storage = FlutterSecureStorage();
    try {
      setState(() => writing = true);
      storage.write(key: MASTER_KEY_STORAGE_KEY, value: masterKey);
      setState(() => writing = false);
    } catch (e) {
      error = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!), duration: Durations.long1),
      );
    }
  }

  void submit() {
    writeMasterKey();
    Navigator.pushReplacement(context, SmoothRouter.builder(StoragePage()));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: submit,
        icon: Container(
          width: 25.em,
          height: 15.em,
          decoration: BoxDecoration(
            color: enteredMK ? DefaultColors.constant : DefaultColors.shade_2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            writing ? Icons.sync : Icons.navigate_next_rounded,
            color: enteredMK ? DefaultColors.bg : DefaultColors.fg,
            size: 12.em,
          ),
        ),
      ),
      body: DefaultTextStyle.merge(
        style: TextStyle(
          decoration: TextDecoration.none,
          color: DefaultColors.fg,
          fontFamily: "朱雀仿宋",
        ),
        child: Container(
          color: DefaultColors.bg,
          child: Padding(
            padding: EdgeInsets.all(12.em),
            child: Column(
              children: [
                // title
                Padding(
                  padding:
                      ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
                          ?
                          // mobile
                          EdgeInsets.symmetric(vertical: 7.5.em)
                          :
                          // desktop / tablet
                          EdgeInsets.zero,
                  child: Text.rich(
                    TextSpan(
                      text: AppLocalizations.of(context)!.mk_title,
                      style: TextStyle(
                        fontSize: 15.em,
                        color: DefaultColors.keyword,
                      ),
                    ),
                  ),
                ),

                // desc
                Text.rich(
                  TextSpan(
                    text: AppLocalizations.of(context)!.mk_desc,
                    style: TextStyle(fontSize: 8.em),
                  ),
                ),

                // override cursor related colors
                Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                      selectionColor: DefaultColors.shade_3,
                      selectionHandleColor: DefaultColors.shade_4,
                    ),
                  ),
                  child: Padding(
                    padding:
                        ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
                            ?
                            // mobile
                            EdgeInsets.symmetric(vertical: 2.5.em)
                            :
                            // desktop / tablet
                            EdgeInsets.symmetric(
                              vertical: 4.em,
                              horizontal: 50.em,
                            ),
                    child: AutofillGroup(
                      // input field
                      child: TextField(
                        onSubmitted: (_) => submit(),
                        onChanged:
                            (s) => setState(() {
                              masterKey = s;
                              enteredMK = s.isNotEmpty;
                            }),

                        // enable password completion
                        autofillHints: [AutofillHints.password],
                        enableIMEPersonalizedLearning: false,
                        obscureText: !showMK,

                        cursorColor: DefaultColors.shade_6,
                        style: TextStyle(
                          color: DefaultColors.fg,
                          fontSize: 4.em,
                        ),
                        autofocus: true,

                        decoration: InputDecoration(
                          // toggle obscureText
                          suffixIcon: IconButton(
                            color: DefaultColors.info,
                            icon: Icon(
                              showMK ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => showMK = !showMK),
                          ),
                          fillColor: DefaultColors.shade_2,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // warning
                Row(
                  children: [
                    Icon(Icons.warning, color: DefaultColors.error),
                    Text.rich(
                      TextSpan(
                        text: AppLocalizations.of(context)!.mk_warn_title,
                        style: TextStyle(
                          fontSize: 8.em,
                          color: DefaultColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!.mk_warn_desc_1,
                          style: TextStyle(
                            fontSize: 5.em,
                            fontWeight: FontWeight.bold,
                            color: DefaultColors.error,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.mk_warn_desc_2,
                          style: TextStyle(
                            fontSize: 5.em,
                            fontStyle: FontStyle.italic,
                            color: DefaultColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: Duration(milliseconds: 500));
  }
}
