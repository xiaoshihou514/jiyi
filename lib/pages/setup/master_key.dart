import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/pages/home.dart';

import 'package:jiyi/utils/em.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/setup/storage.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/smooth_router.dart';

const durationDim = Duration(seconds: 2);

class MasterKeyPage extends StatefulWidget {
  final String? storagePath;
  const MasterKeyPage(this.storagePath, {super.key});

  @override
  State<MasterKeyPage> createState() => _MasterKeyPage();
}

class _MasterKeyPage extends State<MasterKeyPage> {
  // text field state
  bool _showMK = false;
  final _controller = TextEditingController();

  // float button ui state
  bool get _enteredMK => _controller.text.isNotEmpty;
  bool _writing = false;

  // error handling and display
  String? _error;

  Future<void> _writeMasterKey() async {
    try {
      setState(() => _writing = true);
      ss.write(key: ss.MASTER_KEY_KEY, value: _controller.text);
      setState(() => _writing = false);
    } catch (e) {
      _error = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!), duration: Durations.long1),
      );
    }
  }

  void _submit() {
    _writeMasterKey();
    Navigator.pushReplacement(
      context,
      SmoothRouter.builder(
        widget.storagePath == null
            ? StoragePage(_controller.text)
            : HomePage(true, widget.storagePath!, _controller.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: () {
          if (_enteredMK) {
            _submit();
          }
        },
        icon: Container(
          width: 25.em,
          height: 15.em,
          decoration: BoxDecoration(
            color: _enteredMK ? DefaultColors.constant : DefaultColors.shade_2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _writing
              ? Spinner(Icons.sync, DefaultColors.bg, 12.em)
              : Icon(
                  Icons.navigate_next_rounded,
                  color: _enteredMK ? DefaultColors.bg : DefaultColors.fg,
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
                  padding: ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
                      ?
                        // mobile
                        EdgeInsets.symmetric(vertical: 7.5.em)
                      :
                        // desktop / tablet
                        EdgeInsets.zero,
                  child: Text.rich(
                    TextSpan(
                      text: l.mk_title,
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
                    text: l.mk_desc,
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
                    padding: ScreenUtil().scaleWidth < ScreenUtil().scaleHeight
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
                        onSubmitted: (_) => _submit(),
                        controller: _controller,

                        // enable password completion
                        autofillHints: [AutofillHints.password],
                        enableIMEPersonalizedLearning: false,
                        obscureText: !_showMK,

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
                              _showMK ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => _showMK = !_showMK),
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
                            borderRadius: BorderRadius.circular(15),
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
                        text: l.mk_warn_title,
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
                          text: l.mk_warn_desc_1,
                          style: TextStyle(
                            fontSize: 5.em,
                            fontWeight: FontWeight.bold,
                            color: DefaultColors.error,
                          ),
                        ),
                        TextSpan(
                          text: l.mk_warn_desc_2,
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
