import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/components/style/settings.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/data/asr_setting.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:jiyi/utils/anno.dart';
import 'package:url_launcher/url_launcher.dart';

@DeepSeek()
class ASRSettings extends StatefulWidget {
  final AppLocalizations loc;
  const ASRSettings(this.loc, {super.key});

  @override
  State<ASRSettings> createState() => _ASRSettingsState();
}

class _ASRSettingsState extends State<ASRSettings> {
  late final AppLocalizations l;
  late AsrSetting _setting;
  late List<String> list;
  List<String>? downloads;

  // Model type controller remains as it's a text input
  final _modelTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    l = widget.loc;
    _setting = AsrSetting(
      encoder: '',
      decoder: '',
      joiner: '',
      tokens: '',
      modelType: '',
    );
    list = [l.settings_asr_custom, l.settings_asr_zh_en_streaming_zipformer];
    _loadASRSettings();
  }

  Future<void> _loadASRSettings() async {
    final settings = await ss.read(key: ss.ASR_MODEL_SETTINGS);
    if (settings != null) {
      setState(() {
        _setting = AsrSetting.fromJson(settings);
        _modelTypeController.text = _setting.modelType;
      });
    }
  }

  void _updateSetting(String field, String value) {
    setState(() {
      _setting = AsrSetting(
        encoder: field == 'encoder' ? value : _setting.encoder,
        decoder: field == 'decoder' ? value : _setting.decoder,
        joiner: field == 'joiner' ? value : _setting.joiner,
        tokens: field == 'tokens' ? value : _setting.tokens,
        modelType: field == 'modelType' ? value : _setting.modelType,
        name: field == 'name' ? value : _setting.name,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.settings_asr_model,
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Settings.settingOpButton(() async {
                  await ss.write(key: ss.ASR_MODEL_SETTINGS, value: null);
                }, Icons.undo),
                Settings.settingOpButton(() async {
                  // Update model type from controller
                  _updateSetting('modelType', _modelTypeController.text);

                  await ss.write(
                    key: ss.ASR_MODEL_SETTINGS,
                    value: _setting.json,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.settings_asr_saved)),
                    );
                  }

                  // preset download logic
                  if (_setting.name != null &&
                      !Directory(
                        path.basename(_setting.encoder),
                      ).existsSync()) {
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
            Text(l.settings_asr_provider),
            DropdownButton(
              value: _setting.name ?? l.settings_asr_custom,
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
                if (value == l.settings_asr_custom) {
                  _setting.name = null;
                  _setting.encoder = '';
                  _setting.decoder = '';
                  _setting.joiner = '';
                  _setting.tokens = '';
                  _setting.modelType = '';
                } else {
                  _usePreset(value!);
                }
              }),
              items: list
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
            ),
          ],
        ),

        if (_setting.name == null) _localASRSettings(),
      ],
    );
  }

  Widget _localASRSettings() => Column(
    children: [
      // Encoder model path
      Settings.flex(
        children: [
          Text(l.settings_asr_encoder),
          Settings.buildFileChooser(
            () => _selectModelFile('encoder'),
            Icons.file_open,
            _setting.encoder.isEmpty
                ? Text(l.settings_asr_picker_desc, style: _hintStyle)
                : Text(path.basename(_setting.encoder), style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // Decoder model path
      Settings.flex(
        children: [
          Text(l.settings_asr_decoder),
          Settings.buildFileChooser(
            () => _selectModelFile('decoder'),
            Icons.file_open,
            _setting.decoder.isEmpty
                ? Text(l.settings_asr_picker_desc, style: _hintStyle)
                : Text(path.basename(_setting.decoder), style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // Joiner model path
      Settings.flex(
        children: [
          Text(l.settings_asr_joiner),
          Settings.buildFileChooser(
            () => _selectModelFile('joiner'),
            Icons.file_open,
            _setting.joiner.isEmpty
                ? Text(l.settings_asr_picker_desc, style: _hintStyle)
                : Text(path.basename(_setting.joiner), style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // Tokens file path
      Settings.flex(
        children: [
          Text(l.settings_asr_tokens),
          Settings.buildFileChooser(
            () => _selectModelFile('tokens'),
            Icons.file_open,
            _setting.tokens.isEmpty
                ? Text(l.settings_asr_picker_desc, style: _hintStyle)
                : Text(path.basename(_setting.tokens), style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // Model type
      Settings.flex(
        children: [
          Text(l.settings_asr_model_type),
          SizedBox(
            height: 6.em,
            width: 50.em,
            child: TextField(
              controller: _modelTypeController,
              style: _inputStyle,
              decoration: _inputDecoration,
              onChanged: (value) => _updateSetting('modelType', value),
            ),
          ),
        ],
      ),
      InkWell(
        child: Text(
          l.settings_asr_download_desc,
          style: TextStyle(
            decoration: TextDecoration.underline,
            decorationColor: DefaultColors.info,
            color: DefaultColors.info,
          ),
        ),
        onTap: () => launchUrl(
          Uri.parse(
            "https://github.com/k2-fsa/sherpa-onnx/releases/tag/asr-models",
          ),
        ),
      ),
      Text(
        l.settings_asr_download_exp,
        style: TextStyle(color: DefaultColors.fg),
      ),
    ],
  );

  TextStyle get _hintStyle =>
      TextStyle(fontSize: 5.em, color: DefaultColors.bg, fontFamily: "朱雀仿宋");

  TextStyle get _fileStyle =>
      TextStyle(fontSize: 3.em, color: DefaultColors.bg, fontFamily: "朱雀仿宋");

  TextStyle get _inputStyle => TextStyle(
    color: DefaultColors.fg,
    fontSize: Settings.isMobile ? 4.em : 3.em,
  );

  InputDecoration get _inputDecoration => InputDecoration(
    contentPadding: Settings.isMobile
        ? null
        : EdgeInsets.symmetric(vertical: 1.em),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: DefaultColors.fg),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: DefaultColors.fg),
    ),
  );

  Future<void> _selectModelFile(String field) async {
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
      _updateSetting(field, result.files.single.path!);
    }
  }

  Future<void> _usePreset(String name) async {
    _setting.name = name;
    if (name == l.settings_asr_zh_en_streaming_zipformer) {
      final dest = (await getApplicationSupportDirectory()).path;
      final prefix =
          "sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20";
      _setting.encoder = path.join(
        dest,
        prefix,
        "encoder-epoch-99-avg-1.int8.onnx",
      );
      _setting.decoder = path.join(
        dest,
        prefix,
        "decoder-epoch-99-avg-1.int8.onnx",
      );
      _setting.joiner = path.join(
        dest,
        prefix,
        "joiner-epoch-99-avg-1.int8.onnx",
      );
      _setting.tokens = path.join(dest, prefix, "tokens.txt");
      _setting.modelType = 'zipformer';
      if (l.localeName.contains("zh")) {
        // ghfast.top墙内加速
        downloads = [
          "https://ghfast.top/github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20.tar.bz2",
        ];
      } else {
        downloads = [
          "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20.tar.bz2",
        ];
      }
    }
  }
}
