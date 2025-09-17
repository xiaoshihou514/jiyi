import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jiyi/pages/record.dart';
import 'package:jiyi/utils/data/tts_setting.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;
import 'package:intl/intl.dart';
import 'package:jiyi/components/style/popup.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/src/rust/frb_generated.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/data/llm_setting.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/tts.dart';
import 'package:wav/wav.dart';

@DeepSeek()
class MdEdit extends StatefulWidget {
  final Metadata _md;
  const MdEdit(this._md, {super.key});

  @override
  State<MdEdit> createState() => _MdEditState();
}

class _MdEditState extends State<MdEdit> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _coverController = TextEditingController();
  final _transcriptController = TextEditingController();

  LLMSetting? _llmSetting;
  so.OnlineModelConfig? _ttsSetting;

  @override
  void initState() {
    super.initState();
    // 使用传入的元数据初始化表单
    _selectedDate = widget._md.time;
    _selectedTime = TimeOfDay.fromDateTime(widget._md.time);
    _titleController.text = widget._md.title;
    _latController.text = widget._md.latitude?.toString() ?? '';
    _lonController.text = widget._md.longitude?.toString() ?? '';
    _coverController.text = widget._md.cover;
    _transcriptController.text = widget._md.transcript;
    _readSettings();
  }

  Future<void> _readSettings() async {
    final s1 = await ss.read(key: ss.LLM_MODEL_SETTINGS);
    final s2 = await ss.read(key: ss.TTS_MODEL_SETTINGS);
    setState(() {
      if (s1 != null) {
        _llmSetting = LLMSetting.fromJson(s1);
      }
      if (s2 != null) {
        _ttsSetting = TtsSetting.fromJson(s2).model;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _coverController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 创建更新后的元数据对象
    final updated = Metadata(
      time: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      length: widget._md.length, // 时长保持不变
      title: _titleController.text,
      latitude: _latController.text.isNotEmpty
          ? double.parse(_latController.text)
          : null,
      longitude: _lonController.text.isNotEmpty
          ? double.parse(_lonController.text)
          : null,
      cover: _coverController.text,
      path: widget._md.path, // 路径保持不变
      transcript: _transcriptController.text,
    );

    IO.updateMetadata(widget._md, updated);

    Navigator.pop(context, updated);
  }

  Future<void> _zdpp() async {
    await RustLib.init();
    final enhanced = Tts.llmEnhance(_transcriptController.text, _llmSetting!);
    setState(() => _transcriptController.text = enhanced);
  }

  Future<void> _rebuildTranscript() async {
    final data = Float32List.fromList(
      Wav.read(await IO.read(widget._md.path)).channels.first.toList(),
    );
    final newTranscript = await Tts.fromWAV(
      _ttsSetting,
      _llmSetting,
      data,
      SAMPLE_RATE,
    );
    setState(() => _transcriptController.text = newTranscript);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: DefaultColors.bg,
      title: Text(
        l.metadata_edit_title,
        style: TextStyle(
          color: DefaultColors.fg,
          fontSize: 4.5.em,
          fontFamily: "朱雀仿宋",
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 音频时长显示（只读）
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.em),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, size: 4.em, color: DefaultColors.info),
                    SizedBox(width: 1.em),
                    Text(
                      '${l.metadata_duration}: ${Popup.formatDuration(widget._md.length)}',
                      style: TextStyle(
                        color: DefaultColors.fg,
                        fontSize: 3.5.em,
                        fontFamily: "朱雀仿宋",
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 4.em, color: DefaultColors.shade_3),

              // 日期时间选择器
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  DateFormat("yyyy-MM-dd HH:mm").format(
                    DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    ),
                  ),
                  style: TextStyle(
                    color: DefaultColors.fg,
                    fontSize: 3.5.em,
                    fontFamily: "朱雀仿宋",
                  ),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: DefaultColors.func,
                  size: 4.em,
                ),
                onTap: () => Popup.selectDateTime(
                  context,
                  (date, time) => setState(() {
                    _selectedDate = date;
                    _selectedTime = time;
                  }),
                ),
              ),
              SizedBox(height: 4.em),

              // 标题输入
              TextFormField(
                controller: _titleController,
                decoration: Popup.buildInputDecoration(
                  '${l.metadata_title_label}*',
                  null,
                ),
                cursorColor: DefaultColors.func,
                style: TextStyle(
                  color: DefaultColors.fg,
                  fontSize: 3.5.em,
                  fontFamily: "朱雀仿宋",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l.metadata_title_required;
                  }
                  return null;
                },
              ),
              SizedBox(height: 4.em),

              // 封面emoji输入
              TextFormField(
                cursorColor: DefaultColors.func,
                controller: _coverController,
                decoration: Popup.buildInputDecoration(
                  '${l.metadata_cover_label}*',
                  null,
                ),
                style: TextStyle(
                  color: DefaultColors.fg,
                  fontSize: 3.5.em,
                  fontFamily: "朱雀仿宋",
                ),
                maxLength: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l.metadata_cover_required;
                  }
                  return null;
                },
              ),
              SizedBox(height: 1.em),

              // 经纬度输入
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: DefaultColors.func,
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: Popup.buildInputDecoration(
                        l.metadata_latitude,
                        l.metadata_latitude_hint,
                      ),
                      style: TextStyle(
                        color: DefaultColors.fg,
                        fontSize: 3.5.em,
                        fontFamily: "朱雀仿宋",
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final lat = double.tryParse(value);
                          if (lat == null || lat < -90 || lat > 90) {
                            return l.metadata_invalid_latitude;
                          }
                        }
                        return null;
                      },
                    ),
                  ),

                  SizedBox(width: 4.em),

                  Expanded(
                    child: TextFormField(
                      cursorColor: DefaultColors.func,
                      controller: _lonController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: Popup.buildInputDecoration(
                        l.metadata_longitude,
                        l.metadata_longitude_hint,
                      ),
                      style: TextStyle(
                        color: DefaultColors.fg,
                        fontSize: 3.5.em,
                        fontFamily: "朱雀仿宋",
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final lon = double.tryParse(value);
                          if (lon == null || lon < -180 || lon > 180) {
                            return l.metadata_invalid_longitude;
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.em),

              // 转录文本输入
              ConstrainedBox(
                constraints: BoxConstraints.tightFor(width: 80.em),
                child: TextFormField(
                  cursorColor: DefaultColors.func,
                  controller: _transcriptController,
                  decoration: Popup.buildInputDecoration(
                    l.metadata_transcript_label,
                    l.metadata_transcript_hint,
                  ),
                  style: TextStyle(
                    color: DefaultColors.fg,
                    fontSize: 3.5.em,
                    fontFamily: "朱雀仿宋",
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l.metadata_cancel,
            style: TextStyle(
              color: DefaultColors.error,
              fontSize: 3.5.em,
              fontFamily: "朱雀仿宋",
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DefaultColors.func,
            foregroundColor: DefaultColors.bg,
            padding: EdgeInsets.symmetric(horizontal: 4.em, vertical: 2.em),
          ),
          onPressed: _saveChanges,
          child: Text(
            l.metadata_save,
            style: TextStyle(fontSize: 3.5.em, fontFamily: "朱雀仿宋"),
          ),
        ),
        _ttsSetting != null
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.keyword,
                  foregroundColor: DefaultColors.bg,
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.em,
                    vertical: 2.em,
                  ),
                ),
                onPressed: _rebuildTranscript,
                child: Text(
                  l.metadata_rebuild_transcript,
                  style: TextStyle(fontSize: 3.5.em, fontFamily: "朱雀仿宋"),
                ),
              )
            : TextButton(
                onPressed: () {},
                child: Text(
                  l.metadata_missing_llm_setting,
                  style: TextStyle(
                    color: DefaultColors.shade_6,
                    fontSize: 3.5.em,
                    fontFamily: "朱雀仿宋",
                  ),
                ),
              ),
        _llmSetting != null
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.keyword,
                  foregroundColor: DefaultColors.bg,
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.em,
                    vertical: 2.em,
                  ),
                ),
                onPressed: _zdpp,
                child: Text(
                  l.metadata_zdpp,
                  style: TextStyle(fontSize: 3.5.em, fontFamily: "朱雀仿宋"),
                ),
              )
            : TextButton(
                onPressed: () {},
                child: Text(
                  l.metadata_missing_llm_setting,
                  style: TextStyle(
                    color: DefaultColors.shade_6,
                    fontSize: 3.5.em,
                    fontFamily: "朱雀仿宋",
                  ),
                ),
              ),
      ],
    );
  }
}

// 暴露的对话框接口
Future<Metadata?> showMetadataEditDialog(
  BuildContext context,
  Metadata metadata,
) async {
  return showDialog<Metadata>(
    context: context,
    builder: (context) => MdEdit(metadata),
  );
}
