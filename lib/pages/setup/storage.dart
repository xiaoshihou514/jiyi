import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/components/spinner.dart';

import 'package:jiyi/utils/em.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/pages/home.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/smooth_router.dart';
import 'package:permission_handler/permission_handler.dart';

class StoragePage extends StatefulWidget {
  final String masterKey;
  const StoragePage(this.masterKey, {super.key});

  @override
  State<StoragePage> createState() => _StoragePage();
}

class _StoragePage extends State<StoragePage> {
  // float button ui state
  bool _choosen = false;
  bool _writing = false;

  // error handling and display
  String? _error;

  String _storagePath = "";

  Future<void> _writeStoragePath() async {
    try {
      setState(() => _writing = true);
      ss.write(key: ss.STORAGE_PATH, value: _storagePath);
      setState(() => _writing = false);
    } catch (e) {
      _error = e.toString();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_error!), duration: Durations.long1),
      );
    }
  }

  void _submit() {
    _writeStoragePath();
    Navigator.pushReplacement(
      context,
      SmoothRouter.builder(HomePage(true, _storagePath, widget.masterKey)),
    );
  }

  Future<void> _choose() async {
    if (Platform.isAndroid) {
      if (!await Permission.storage.status.isGranted) {
        await Permission.storage.request();
      }
      if (!await Permission.manageExternalStorage.status.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
    );

    if (selectedDirectory != null) {
      setState(() {
        _storagePath = selectedDirectory;
        _choosen = true;
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
          if (_choosen) {
            _submit();
          }
        },
        icon: Container(
          width: 25.em,
          height: 15.em,
          decoration: BoxDecoration(
            color: _choosen ? DefaultColors.constant : DefaultColors.shade_2,
            borderRadius: BorderRadius.circular(10),
          ),
          child: _writing
              ? Spinner(Icons.sync, DefaultColors.bg, 12.em)
              : Icon(
                  Icons.navigate_next_rounded,
                  color: _choosen ? DefaultColors.bg : DefaultColors.fg,
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
                  child: Text(
                    l.st_title,
                    style: TextStyle(
                      fontSize: 15.em,
                      color: DefaultColors.keyword,
                    ),
                  ),
                ),

                // desc
                Text(l.st_desc, style: TextStyle(fontSize: 8.em)),

                // button
                Center(
                  heightFactor: 1.5,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: _choose,
                        iconSize: 12.em,
                        alignment: Alignment.center,
                        icon: Container(
                          decoration: BoxDecoration(
                            color: _choosen
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
                                Text(
                                  l.st_hint,
                                  style: TextStyle(
                                    fontSize: 8.em,
                                    color: DefaultColors.bg,
                                    fontFamily: "朱雀仿宋",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // hint
                      Text(
                        _choosen
                            ? l.st_path_prefix + _storagePath
                            : l.st_path_placeholder,
                        style: TextStyle(fontSize: 4.em),
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
