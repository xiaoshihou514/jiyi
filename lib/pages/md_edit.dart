import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiyi/pages/record.dart';
import 'package:jiyi/services/geo.dart';
import 'package:jiyi/utils/data/asr_setting.dart';
import 'package:jiyi/utils/data/zdpp_setting.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;
import 'package:intl/intl.dart';
import 'package:jiyi/components/style/popup.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/services/io.dart';
import 'package:jiyi/services/secure_storage.dart' as ss;
import 'package:jiyi/utils/asr.dart';
import 'package:wav/wav.dart';

@DeepSeek()
class MdEditPage extends StatefulWidget {
  final Metadata _md;
  const MdEditPage(this._md, {super.key});

  @override
  State<MdEditPage> createState() => _MdEditPageState();
}

class _MdEditPageState extends State<MdEditPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _coverController = TextEditingController();
  final _transcriptController = TextEditingController();
  @Claude()
  String? _geodesc;

  so.OfflinePunctuationConfig? _zdppSetting;
  so.OnlineModelConfig? _asrSetting;

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
    _geodesc = widget._md.geodesc;
    _readSettings();
  }

  Future<void> _readSettings() async {
    final s1 = await ss.read(key: ss.ZDPP_MODEL_SETTINGS);
    final s2 = await ss.read(key: ss.ASR_MODEL_SETTINGS);
    setState(() {
      if (s1 != null) {
        _zdppSetting = ZdppSetting.fromJson(s1).model;
      }
      if (s2 != null) {
        _asrSetting = AsrSetting.fromJson(s2).model;
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
      geodesc: _geodesc,
    );

    IO.updateMetadata(widget._md, updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.metadata_saved),
        backgroundColor: DefaultColors.keyword,
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.pop(context, updated);
  }

  Future<void> _zdpp() async {
    setState(
      () => _transcriptController.text = Asr.zdpp(
        _transcriptController.text,
        _zdppSetting!,
      ),
    );
  }

  Future<void> _rebuildTranscript() async {
    final data = Float32List.fromList(
      Wav.read(await IO.read(widget._md.path)).channels.first.toList(),
    );
    final newTranscript = await Asr.fromWAV(
      _asrSetting,
      _zdppSetting,
      data,
      SAMPLE_RATE,
    );
    setState(() => _transcriptController.text = newTranscript);
  }

  @Claude()
  Future<void> _lookupLocation() async {
    if (widget._md.latitude == null || widget._md.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.geo_lookup_missing_coords),
          backgroundColor: DefaultColors.error,
        ),
      );
      return;
    }

    final geo = Geo();
    final locationDesc = await geo.getLocationDescription(
      widget._md.latitude!,
      widget._md.longitude!,
    );

    if (locationDesc != null) {
      setState(() {
        _geodesc = locationDesc;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.geo_lookup_success),
            backgroundColor: DefaultColors.keyword,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.geo_lookup_failed),
          backgroundColor: DefaultColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DefaultColors.bg,
        title: Text(
          l.metadata_edit_title,
          style: TextStyle(
            color: DefaultColors.fg,
            fontSize: 4.5.em,
            fontFamily: "朱雀仿宋",
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: DefaultColors.fg, size: 4.em),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              l.metadata_save,
              style: TextStyle(
                color: DefaultColors.func,
                fontSize: 3.5.em,
                fontFamily: "朱雀仿宋",
              ),
            ),
          ),
        ],
      ),
      backgroundColor: DefaultColors.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              TextFormField(
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

              SizedBox(height: 4.em),

              // ASR相关按钮区域
              if (_asrSetting != null || _zdppSetting != null)
                Wrap(
                  spacing: 16.0,
                  runSpacing: 8.0,
                  children: [
                    if (_asrSetting != null)
                      ElevatedButton(
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
                          style: TextStyle(
                            fontSize: 3.5.em,
                            fontFamily: "朱雀仿宋",
                          ),
                        ),
                      ),
                    if (_zdppSetting != null)
                      ElevatedButton(
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
                          style: TextStyle(
                            fontSize: 3.5.em,
                            fontFamily: "朱雀仿宋",
                          ),
                        ),
                      ),
                  ],
                ),

              if (_asrSetting != null || _zdppSetting != null)
                SizedBox(height: 4.em),

              // 当前地理位置显示
              Padding(
                padding: EdgeInsets.symmetric(vertical: 2.em),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 4.em,
                      color: DefaultColors.info,
                    ),
                    SizedBox(width: 1.em),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.metadata_location_display(
                          _geodesc ?? AppLocalizations.of(context)!.metadata_location_unset,
                        ),
                        style: TextStyle(
                          color: DefaultColors.fg,
                          fontSize: 3.5.em,
                          fontFamily: "朱雀仿宋",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 4.em, color: DefaultColors.shade_3),

              // 地理位置查询按钮
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.func,
                  foregroundColor: DefaultColors.bg,
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.em,
                    vertical: 2.em,
                  ),
                ),
                onPressed: _lookupLocation,
                child: Text(
                  '查询位置',
                  style: TextStyle(fontSize: 3.5.em, fontFamily: "朱雀仿宋"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 暴露的页面导航接口
void navigateToMetadataEditPage(BuildContext context, Metadata metadata) {
  Navigator.push<Metadata>(
    context,
    MaterialPageRoute(builder: (context) => MdEditPage(metadata)),
  );
}
