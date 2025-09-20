// ignore_for_file: constant_identifier_names

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

const TRANSDUCER = "transducer";
const PARAFORMER = "paraformer";
const ZIPFORMER2CTC = "zipformer2Ctc";
const NEMOCTC = "nemoCtc";
const TONECTC = "toneCtc";
const ASR_TYPES = [TRANSDUCER, PARAFORMER, ZIPFORMER2CTC, NEMOCTC, TONECTC];
const ASR_TYPES_ENCODER = [TRANSDUCER, PARAFORMER];
const ASR_TYPES_DECODER = [TRANSDUCER, PARAFORMER];
const ASR_TYPES_JOINER = [TRANSDUCER];
const ASR_TYPES_SINGLE = [ZIPFORMER2CTC, NEMOCTC, TONECTC];

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
  late List<String> customAndPresets;
  List<String>? downloads;

  @override
  void initState() {
    super.initState();
    l = widget.loc;
    _setting = AsrSetting(tokens: '', modelType: 'transducer');
    customAndPresets = [
      l.settings_asr_custom,
      l.settings_asr_zh_en_streaming_zipformer,
      l.settings_asr_zh_en_streaming_paraformer,
      l.settings_asr_zh_streaming_ctc,
      l.settings_asr_en_nemo_ctc,
    ];
    _loadASRSettings();
  }

  Future<void> _loadASRSettings() async {
    final settings = await ss.read(key: ss.ASR_MODEL_SETTINGS);
    if (settings != null) {
      setState(() => _setting = AsrSetting.fromJson(settings));
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
              l.settings_asr_model,
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Settings.settingOpButton(() async {
                  await ss.write(key: ss.ASR_MODEL_SETTINGS, value: null);
                }, Icons.undo),
                Settings.settingOpButton(() async {
                  if (_setting.tokens.isEmpty) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settings_asr_missing_fields)),
                      );
                    }
                    return;
                  } else if (_setting.modelType == "transducer" &&
                      [
                        _setting.encoder,
                        _setting.decoder,
                        _setting.joiner,
                      ].any((x) => x == null)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settings_asr_missing_fields)),
                      );
                    }
                    return;
                  } else if (_setting.modelType == "paraformer" &&
                      [
                        _setting.encoder,
                        _setting.decoder,
                      ].any((x) => x == null)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settings_asr_missing_fields)),
                      );
                    }
                    return;
                  } else if (_setting.modelType == "zipformer2Ctc" &&
                      _setting.single == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settings_asr_missing_fields)),
                      );
                    }
                    return;
                  } else if (_setting.modelType == "nemoCtc" &&
                      _setting.single == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settings_asr_missing_fields)),
                      );
                    }
                    return;
                  } else if (_setting.modelType == "toneCtc" &&
                      _setting.single == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settings_asr_missing_fields)),
                      );
                    }
                    return;
                  }

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
                        // hack
                        path.dirname((_setting.single ?? _setting.encoder)!),
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
                  _setting.encoder = null;
                  _setting.decoder = null;
                  _setting.joiner = null;
                  _setting.tokens = "";
                  _setting.modelType = 'transducer';
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

        if (_setting.name == null) _localASRSettings(),
      ],
    );
  }

  Widget _localASRSettings() => Column(
    children: [
      // Single model path
      if (ASR_TYPES_SINGLE.contains(_setting.modelType))
        Settings.flex(
          children: [
            Text(l.settings_asr_single),
            Settings.buildFileChooser(
              () => _selectModelFile((p, s) => s.single = p),
              Icons.file_open,
              _setting.single == null
                  ? Text(
                      l.settings_asr_picker_desc,
                      style: Settings.fBHintStyle,
                    )
                  : Text(
                      path.basename(_setting.single!),
                      style: Settings.fBFileStyle,
                    ),
              DefaultColors.constant,
            ),
          ],
        ),

      // Encoder model path
      if (ASR_TYPES_ENCODER.contains(_setting.modelType))
        Settings.flex(
          children: [
            Text(l.settings_asr_encoder),
            Settings.buildFileChooser(
              () => _selectModelFile((p, s) => s.encoder = p),
              Icons.file_open,
              _setting.encoder == null
                  ? Text(
                      l.settings_asr_picker_desc,
                      style: Settings.fBHintStyle,
                    )
                  : Text(
                      path.basename(_setting.encoder!),
                      style: Settings.fBFileStyle,
                    ),
              DefaultColors.constant,
            ),
          ],
        ),

      // Decoder model path
      if (ASR_TYPES_DECODER.contains(_setting.modelType))
        Settings.flex(
          children: [
            Text(l.settings_asr_decoder),
            Settings.buildFileChooser(
              () => _selectModelFile((p, s) => s.decoder = p),
              Icons.file_open,
              _setting.decoder == null
                  ? Text(
                      l.settings_asr_picker_desc,
                      style: Settings.fBHintStyle,
                    )
                  : Text(
                      path.basename(_setting.decoder!),
                      style: Settings.fBFileStyle,
                    ),
              DefaultColors.constant,
            ),
          ],
        ),

      // Joiner model path
      if (ASR_TYPES_JOINER.contains(_setting.modelType))
        Settings.flex(
          children: [
            Text(l.settings_asr_joiner),
            Settings.buildFileChooser(
              () => _selectModelFile((p, s) => s.joiner = p),
              Icons.file_open,
              _setting.joiner == null
                  ? Text(
                      l.settings_asr_picker_desc,
                      style: Settings.fBHintStyle,
                    )
                  : Text(
                      path.basename(_setting.joiner!),
                      style: Settings.fBFileStyle,
                    ),
              DefaultColors.constant,
            ),
          ],
        ),

      // Tokens file path
      Settings.flex(
        children: [
          Text(l.settings_asr_tokens),
          Settings.buildFileChooser(
            () => _selectModelFile((p, s) => s.tokens = p),
            Icons.file_open,
            _setting.tokens.isEmpty
                ? Text(l.settings_asr_picker_desc, style: Settings.fBHintStyle)
                : Text(
                    path.basename(_setting.tokens),
                    style: Settings.fBFileStyle,
                  ),
            DefaultColors.constant,
          ),
        ],
      ),

      // Model type
      Settings.flex(
        children: [
          Text(l.settings_asr_model_type),
          DropdownButton(
            value: _setting.modelType,
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
              if (value != null) {
                _setting.modelType = value;
              }
            }),
            items: ASR_TYPES
                .map(
                  (String value) =>
                      DropdownMenuItem(value: value, child: Text(value)),
                )
                .toList(),
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

  Future<void> _selectModelFile(
    void Function(String, AsrSetting) modify,
  ) async {
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
      setState(() => modify(result.files.single.path!, _setting));
    }
  }

  Future<void> _usePreset(String name) async {
    _setting.name = name;
    // ghfast.top墙内加速
    final urlPrefix = l.localeName.contains("zh")
        ? "https://ghfast.top/github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/"
        : "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/";
    final dest = (await getApplicationSupportDirectory()).path;

    if (name == l.settings_asr_zh_en_streaming_zipformer) {
      final name = "sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20";
      _setting.encoder = path.join(
        dest,
        name,
        "encoder-epoch-99-avg-1.int8.onnx",
      );
      _setting.decoder = path.join(
        dest,
        name,
        "decoder-epoch-99-avg-1.int8.onnx",
      );
      _setting.joiner = path.join(
        dest,
        name,
        "joiner-epoch-99-avg-1.int8.onnx",
      );
      _setting.tokens = path.join(dest, name, "tokens.txt");
      _setting.modelType = TRANSDUCER;
      downloads = ["$urlPrefix/$name.tar.bz2"];
    } else if (name == l.settings_asr_zh_en_streaming_paraformer) {
      final name = "sherpa-onnx-streaming-paraformer-bilingual-zh-en";
      _setting.encoder = path.join(dest, name, "encoder.onnx");
      _setting.decoder = path.join(dest, name, "decoder.onnx");
      _setting.tokens = path.join(dest, name, "tokens.txt");
      _setting.modelType = PARAFORMER;
      downloads = ["$urlPrefix/$name.tar.bz2"];
    } else if (name == l.settings_asr_zh_streaming_ctc) {
      final name =
          "sherpa-onnx-streaming-zipformer-ctc-zh-xlarge-int8-2025-06-30";
      _setting.single = path.join(dest, name, "model.int8.onnx");
      _setting.tokens = path.join(dest, name, "tokens.txt");
      _setting.modelType = ZIPFORMER2CTC;
      downloads = ["$urlPrefix/$name.tar.bz2"];
    } else if (name == l.settings_asr_en_nemo_ctc) {
      final name = "sherpa-onnx-nemo-ctc-en-conformer-small";
      _setting.single = path.join(dest, name, "model.int8.onnx");
      _setting.tokens = path.join(dest, name, "tokens.txt");
      _setting.modelType = NEMOCTC;
      downloads = ["$urlPrefix/$name.tar.bz2"];
    }
  }
}
