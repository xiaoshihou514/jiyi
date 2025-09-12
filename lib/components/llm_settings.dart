import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/data/llm_setting.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/components/settings_utils.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LLMSettings extends StatefulWidget {
  final AppLocalizations loc;
  const LLMSettings(this.loc, {super.key});

  @override
  State<LLMSettings> createState() => _LLMSettingsState();
}

class _LLMSettingsState extends State<LLMSettings> {
  late List<String> list;
  late final AppLocalizations l;
  late LLMSetting _setting;
  List<String>? _download;

  final _promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
    l = widget.loc;
    list = [l.settings_llm_zdpp_custom, l.settings_llm_zdpp_qwen3_1_5B];
    _setting = LLMSetting(rootPath: '', prompt: '');
    _loadLLMSettings();
  }

  Future<void> _loadLLMSettings() async {
    final settings = await ss.read(key: ss.LLM_MODEL_SETTINGS);
    if (settings != null) {
      setState(() {
        _setting = LLMSetting.fromJson(settings);
        print(_setting.dyn);
        _promptController.text = _setting.prompt;
      });
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
              l.settings_llm_zdpp_model,
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () async {
                if (_setting.name != null &&
                    !Directory(_setting.rootPath).existsSync()) {
                  // preset download logic
                  final dest = (await getApplicationSupportDirectory()).path;
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          DownloadUnzipDialog(urls: _download!, dest: dest),
                    );
                  }
                }

                await ss.write(
                  key: ss.LLM_MODEL_SETTINGS,
                  value: _setting.json,
                );
                print(_setting.dyn);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.settings_llm_zdpp_saved)),
                  );
                }
              },
              iconSize: 6.em,
              alignment: Alignment.center,
              icon: Container(
                decoration: BoxDecoration(
                  color: DefaultColors.info,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.em,
                    vertical: 1.em,
                  ),
                  child: Icon(Icons.save, color: DefaultColors.bg),
                ),
              ),
            ),
          ],
        ),
        SUtils.flex(
          children: [
            Text(
              l.settings_llm_zdpp_desc,
              style: TextStyle(color: DefaultColors.keyword, fontSize: 4.em),
            ),
          ],
        ),

        SUtils.flex(
          children: [
            Text(l.settings_llm_zdpp_provider),
            DropdownButton(
              value: _setting.name ?? l.settings_llm_zdpp_custom,
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
              onChanged: (String? value) {
                if (value == l.settings_llm_zdpp_custom) {
                  setState(() {
                    _setting.rootPath = "";
                    _setting.prompt = l.tts_opt_prompt;
                    _setting.name = null;
                  });
                } else if (value != null) {
                  _usePreset(value);
                }
              },
              items: list
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
            ),
          ],
        ),

        if (_setting.name == null) _localLLMSettings(),
      ],
    );
  }

  Widget _localLLMSettings() => Column(
    children: [
      // LLM base path
      SUtils.flex(
        children: [
          Text(l.settings_llm_zdpp_root_picker_desc),
          SUtils.buildFileChooser(
            () => _selectLLMPath('encoder'),
            Icons.file_open,
            _setting.rootPath.isEmpty
                ? Text(l.settings_llm_zdpp_root_picker_cover, style: _hintStyle)
                : Text(_setting.rootPath, style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // prompt
      SUtils.flex(
        children: [
          Text(l.settings_llm_zdpp_prompt_desc),
          SizedBox(
            height: 6.em,
            width: 50.em,
            child: TextField(
              controller: _promptController,
              style: _inputStyle,
              decoration: _inputDecoration,
              onChanged: (value) => setState(() => _setting.prompt = value),
            ),
          ),
        ],
      ),
    ],
  );

  TextStyle get _hintStyle =>
      TextStyle(fontSize: 5.em, color: DefaultColors.bg, fontFamily: "朱雀仿宋");

  TextStyle get _fileStyle =>
      TextStyle(fontSize: 3.em, color: DefaultColors.bg, fontFamily: "朱雀仿宋");

  TextStyle get _inputStyle => TextStyle(
    color: DefaultColors.fg,
    fontSize: SUtils.isMobile ? 4.em : 3.em,
  );

  InputDecoration get _inputDecoration => InputDecoration(
    contentPadding: SUtils.isMobile
        ? null
        : EdgeInsets.symmetric(vertical: 1.em),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: DefaultColors.fg),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: DefaultColors.fg),
    ),
  );

  Future<void> _selectLLMPath(String field) async {
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
      setState(() => _setting.rootPath = result.files.single.path!);
    }
  }

  Future<void> _usePreset(String name) async {
    final dest = (await getApplicationSupportDirectory()).path;
    setState(() {
      _setting.rootPath = path.join(dest, name);
      _setting.prompt = l.tts_opt_prompt;
      _setting.name = name;
    });
    if (name == l.settings_llm_zdpp_qwen3_1_5B) {
      final prefix = l.localeName.contains("zh")
          ? "https://hf-mirror.com/Qwen/Qwen3-1.7B/resolve/main"
          : "https://huggingface.co/Qwen/Qwen3-1.7B/resolve/main";
      _download = [
        "$prefix/config.json",
        "$prefix/model.safetensors.index.json",
        "$prefix/model-00001-of-00002.safetensors",
        "$prefix/model-00002-of-00002.safetensors",
        "$prefix/tokenizer.json",
      ];
    }
  }
}
