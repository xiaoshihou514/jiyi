import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:jiyi/em.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/main.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/setup/finish.dart';
import 'package:jiyi/smooth_router.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePage();
}

class _StoragePage extends State<StoragePage> {
  // float button ui state
  bool choosen = false;
  bool writing = false;

  // error handling and display
  String? error;

  String storagePath = "";

  Future writeStoragePath() async {
    final storage = FlutterSecureStorage();
    try {
      setState(() => writing = true);
      storage.write(key: MASTER_KEY_STORAGE_KEY, value: storagePath);
      setState(() => writing = false);
    } catch (e) {
      error = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!), duration: Durations.long1),
      );
    }
  }

  void submit() {
    writeStoragePath();
    Navigator.pushReplacement(context, SmoothRouter.builder(FinishPage()));
  }

  Future choose() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
    );

    if (selectedDirectory != null) {
      setState(() {
        storagePath = selectedDirectory;
        choosen = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: IconButton(
        onPressed: () {
          if (choosen) {
            submit();
          }
        },
        icon: Container(
          width: 25.em,
          height: 15.em,
          decoration: BoxDecoration(
            color: choosen ? DefaultColors.constant : DefaultColors.shade_2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            writing ? Icons.sync : Icons.navigate_next_rounded,
            color: choosen ? DefaultColors.bg : DefaultColors.fg,
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
                      text: l.st_title,
                      style: TextStyle(
                        fontSize: 15.em,
                        color: DefaultColors.keyword,
                      ),
                    ),
                  ),
                ),

                // desc
                Text.rich(
                  TextSpan(text: l.st_desc, style: TextStyle(fontSize: 8.em)),
                ),

                // button
                Center(
                  heightFactor: 1.5,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: choose,
                        iconSize: 12.em,
                        alignment: Alignment.center,
                        icon: Container(
                          decoration: BoxDecoration(
                            color:
                                choosen
                                    ? DefaultColors.constant
                                    : DefaultColors.shade_2,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.em,
                              vertical: 2.em,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              spacing: 5.em,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  color: DefaultColors.bg,
                                ),
                                Text.rich(
                                  TextSpan(
                                    text: l.st_hint,
                                    style: TextStyle(
                                      fontSize: 8.em,
                                      color: DefaultColors.bg,
                                      fontFamily: "朱雀仿宋",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // hint
                      Text.rich(
                        TextSpan(
                          text:
                              choosen
                                  ? l.st_path_prefix + storagePath
                                  : l.st_path_placeholder,
                          style: TextStyle(fontSize: 4.em),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
