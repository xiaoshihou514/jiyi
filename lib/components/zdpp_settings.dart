import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/components/style/settings.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/data/zdpp_setting.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ZdppSettings extends StatefulWidget {
  final AppLocalizations loc;
  const ZdppSettings(this.loc, {super.key});

  @override
  State<ZdppSettings> createState() => _ZdppSettingsState();
}

class _ZdppSettingsState extends State<ZdppSettings> {
  late final AppLocalizations l;
  late ZdppSetting _setting;
  late List<String> customAndPresets;
  List<String>? downloads;

  @override
  void initState() {
    super.initState();
    l = widget.loc;
    _setting = ZdppSetting(name: null, path: '');
    customAndPresets = [
      l.settings_zdpp_custom,
      l.settings_zdpp_zh_en,
      l.settings_zdpp_zh_en_int8,
    ];
    _loadZDPPSettings();
  }

  Future<void> _loadZDPPSettings() async {
    final settings = await ss.read(key: ss.ZDPP_MODEL_SETTINGS);
    if (settings != null) {
      setState(() => _setting = ZdppSetting.fromJson(settings));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.settings_zdpp_model,
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Settings.settingOpButton(() async {
                  await ss.write(key: ss.ZDPP_MODEL_SETTINGS, value: null);
                }, Icons.undo),
                Settings.settingOpButton(() async {
                  // check completeness
                  if (_setting.path.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settings_zdpp_missing_fields)),
                      );
                    }
                    return;
                  }

                  await ss.write(
                    key: ss.ZDPP_MODEL_SETTINGS,
                    value: _setting.json,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.settings_zdpp_saved)),
                    );
                  }

                  // preset download logic
                  if (_setting.name != null &&
                      !Directory(path.dirname(_setting.path)).existsSync()) {
                    final dest = (await getApplicationSupportDirectory()).path;
                    // download
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            DownloadUnzipDialog(urls: downloads!, dest: dest),
                      );
                    }
                  }
                }, Icons.save),
              ],
            ),
          ],
        ),

        Settings.flex(
          children: [
            Text(l.settings_zdpp_provider),
            DropdownButton(
              value: _setting.name ?? l.settings_zdpp_custom,
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
              onChanged: (String? value) => setState(() {
                if (value == l.settings_zdpp_custom) {
                  _setting.name = null;
                  _setting.path = "";
                } else {
                  _usePreset(value!);
                }
              }),
              items: customAndPresets
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
            ),
          ],
        ),

        if (_setting.name == null) _localZDPPSettings(),
      ],
    );
  }

  Widget _localZDPPSettings() => Column(
    children: [
      Settings.flex(
        children: [
          Text(l.settings_zdpp_path),
          Settings.buildFileChooser(
            _selectModelFile,
            Icons.file_open,
            _setting.path.isEmpty
                ? Text(l.settings_asr_picker_desc, style: Settings.fBHintStyle)
                : Text(
                    path.basename(_setting.path),
                    style: Settings.fBFileStyle,
                  ),
            DefaultColors.constant,
          ),
        ],
      ),

      InkWell(
        child: Text(
          l.settings_zdpp_download_desc,
          style: TextStyle(
            decoration: TextDecoration.underline,
            decorationColor: DefaultColors.info,
            color: DefaultColors.info,
          ),
        ),
        onTap: () => launchUrl(
          Uri.parse(
            "https://github.com/k2-fsa/sherpa-onnx/releases/tag/punctuation-models",
          ),
        ),
      ),
      Text(
        l.settings_zdpp_download_exp,
        style: TextStyle(color: DefaultColors.fg),
      ),
    ],
  );

  Future<void> _selectModelFile() async {
    if (Platform.isAndroid) {
      if (!await Permission.storage.status.isGranted) {
        await Permission.storage.request();
      }
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      lockParentWindow: true,
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _setting.path = result.files.single.path!);
    }
  }

  Future<void> _usePreset(String name) async {
    _setting.name = name;
    // ghfast.top墙内加速
    final urlPrefix = l.localeName.contains("zh")
        ? "https://ghfast.top/github.com/k2-fsa/sherpa-onnx/releases/download/punctuation-models/"
        : "https://github.com/k2-fsa/sherpa-onnx/releases/download/punctuation-models/";
    final dest = (await getApplicationSupportDirectory()).path;

    if (name == l.settings_zdpp_zh_en) {
      final name =
          "sherpa-onnx-punct-ct-transformer-zh-en-vocab272727-2024-04-12";
      _setting.path = path.join(dest, name, "model.onnx");
      downloads = ["$urlPrefix/$name.tar.bz2"];
    } else if (name == l.settings_zdpp_zh_en_int8) {
      final name =
          "sherpa-onnx-punct-ct-transformer-zh-en-vocab272727-2024-04-12-int8";
      _setting.path = path.join(dest, name, "model.int8.onnx");
      downloads = ["$urlPrefix/$name.tar.bz2"];
    }
  }
}
