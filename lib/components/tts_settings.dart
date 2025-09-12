import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/tts_setting.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:jiyi/utils/anno.dart';
import 'package:url_launcher/url_launcher.dart';

extension on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? sh / 128
      : sw / 96;
}

bool isMobile = ScreenUtil().screenWidth < ScreenUtil().screenHeight;

@DeepSeek()
class TTSSettings extends StatefulWidget {
  final AppLocalizations loc;
  const TTSSettings(this.loc, {super.key});

  @override
  State<TTSSettings> createState() => _TTSSettingsState();
}

class _TTSSettingsState extends State<TTSSettings> {
  late final AppLocalizations l;
  late TtsSetting _ttsSetting;
  late List<String> list;
  List<String>? downloads;

  // Model type controller remains as it's a text input
  final _modelTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    l = widget.loc;
    _ttsSetting = TtsSetting(
      encoder: '',
      decoder: '',
      joiner: '',
      tokens: '',
      modelType: '',
    );
    list = [l.settings_tts_custom, l.settings_tts_zh_en_streaming_zipformer];
    _loadTTSSettings();
  }

  Future<void> _loadTTSSettings() async {
    final settings = await ss.read(key: ss.TTS_MODEL_SETTINGS);
    if (settings != null) {
      setState(() {
        _ttsSetting = TtsSetting.fromJson(settings);
        _modelTypeController.text = _ttsSetting.modelType;
      });
    }
  }

  void _updateSetting(String field, String value) {
    setState(() {
      _ttsSetting = TtsSetting(
        encoder: field == 'encoder' ? value : _ttsSetting.encoder,
        decoder: field == 'decoder' ? value : _ttsSetting.decoder,
        joiner: field == 'joiner' ? value : _ttsSetting.joiner,
        tokens: field == 'tokens' ? value : _ttsSetting.tokens,
        modelType: field == 'modelType' ? value : _ttsSetting.modelType,
        name: field == 'name' ? value : _ttsSetting.name,
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
              l.settings_tts_model,
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () async {
                // Update model type from controller
                _updateSetting('modelType', _modelTypeController.text);

                print("save");
                print(_ttsSetting.name);
                await ss.write(
                  key: ss.TTS_MODEL_SETTINGS,
                  value: _ttsSetting.json,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.settings_tts_saved)));
                }

                if ([
                  _ttsSetting.encoder,
                  _ttsSetting.decoder,
                  _ttsSetting.joiner,
                  _ttsSetting.tokens,
                ].any((p) => !File(p).existsSync())) {
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

        _flex(
          children: [
            Text(l.settings_tts_provider),
            DropdownButton(
              value: _ttsSetting.name ?? l.settings_tts_custom,
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
                if (value == l.settings_tts_custom) {
                  _ttsSetting.name = null;
                  _ttsSetting.encoder = '';
                  _ttsSetting.decoder = '';
                  _ttsSetting.joiner = '';
                  _ttsSetting.tokens = '';
                  _ttsSetting.modelType = '';
                } else {
                  _usePreset(value!);
                  print("_usePreset");
                  print(_ttsSetting.name);
                  print(_ttsSetting.encoder);
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

        if (_ttsSetting.name == null) _localTTSSettings(),
      ],
    );
  }

  Widget _localTTSSettings() => Column(
    children: [
      // Encoder model path
      _flex(
        children: [
          Text(l.settings_tts_encoder),
          _buildRichButton(
            () => _selectModelFile('encoder'),
            Icons.file_open,
            _ttsSetting.encoder.isEmpty
                ? Text(l.settings_tts_picker_desc, style: _hintStyle)
                : Text(path.basename(_ttsSetting.encoder), style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // Decoder model path
      _flex(
        children: [
          Text(l.settings_tts_decoder),
          _buildRichButton(
            () => _selectModelFile('decoder'),
            Icons.file_open,
            _ttsSetting.decoder.isEmpty
                ? Text(l.settings_tts_picker_desc, style: _hintStyle)
                : Text(path.basename(_ttsSetting.decoder), style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // Joiner model path
      _flex(
        children: [
          Text(l.settings_tts_joiner),
          _buildRichButton(
            () => _selectModelFile('joiner'),
            Icons.file_open,
            _ttsSetting.joiner.isEmpty
                ? Text(l.settings_tts_picker_desc, style: _hintStyle)
                : Text(path.basename(_ttsSetting.joiner), style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // Tokens file path
      _flex(
        children: [
          Text(l.settings_tts_tokens),
          _buildRichButton(
            () => _selectModelFile('tokens'),
            Icons.file_open,
            _ttsSetting.tokens.isEmpty
                ? Text(l.settings_tts_picker_desc, style: _hintStyle)
                : Text(path.basename(_ttsSetting.tokens), style: _fileStyle),
            DefaultColors.constant,
          ),
        ],
      ),

      // Model type
      _flex(
        children: [
          Text(l.settings_tts_model_type),
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
          l.settings_tts_download_desc,
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
        l.settings_tts_download_exp,
        style: TextStyle(color: DefaultColors.fg),
      ),
    ],
  );

  TextStyle get _hintStyle =>
      TextStyle(fontSize: 5.em, color: DefaultColors.bg, fontFamily: "朱雀仿宋");

  TextStyle get _fileStyle =>
      TextStyle(fontSize: 3.em, color: DefaultColors.bg, fontFamily: "朱雀仿宋");

  TextStyle get _inputStyle =>
      TextStyle(color: DefaultColors.fg, fontSize: isMobile ? 4.em : 3.em);

  InputDecoration get _inputDecoration => InputDecoration(
    contentPadding: isMobile ? null : EdgeInsets.symmetric(vertical: 1.em),
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

  IconButton _buildRichButton(
    void Function() callback,
    IconData icon,
    Text text,
    Color bg,
  ) {
    return IconButton(
      onPressed: callback,
      iconSize: 6.em,
      alignment: Alignment.center,
      icon: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.em, vertical: 1.em),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 3.em,
            children: [
              Icon(icon, color: DefaultColors.bg),
              text,
            ],
          ),
        ),
      ),
    );
  }

  Widget _flex({required List<Widget> children}) => isMobile
      ? Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        )
      : Padding(
          padding: EdgeInsets.symmetric(vertical: 2.em),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        );

  Future<void> _usePreset(String name) async {
    _ttsSetting.name = name;
    if (name == l.settings_tts_zh_en_streaming_zipformer) {
      final dest = (await getApplicationSupportDirectory()).path;
      final prefix =
          "sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20";
      _ttsSetting.encoder = path.join(
        dest,
        prefix,
        "encoder-epoch-99-avg-1.int8.onnx",
      );
      _ttsSetting.decoder = path.join(
        dest,
        prefix,
        "decoder-epoch-99-avg-1.int8.onnx",
      );
      _ttsSetting.joiner = path.join(
        dest,
        prefix,
        "joiner-epoch-99-avg-1.int8.onnx",
      );
      _ttsSetting.tokens = path.join(dest, prefix, "tokens.txt");
      _ttsSetting.modelType = 'zipformer';
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
