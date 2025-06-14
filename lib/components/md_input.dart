import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:jiyi/utils/tts.dart';
import 'package:jiyi/utils/tts_setting.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:intl/intl.dart';

import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/encryption.dart';
import 'package:jiyi/utils/metadata.dart';
import 'package:jiyi/utils/io.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wav/wav_file.dart';

extension on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? sh / 128
      : sw / 90;
}

@DeepSeek()
class MetadataInputDialog extends StatefulWidget {
  const MetadataInputDialog({super.key});

  @override
  State<MetadataInputDialog> createState() => _MetadataInputDialogState();
}

class _MetadataInputDialogState extends State<MetadataInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final SoLoud _soloud = SoLoud.instance;
  File? _audioFile;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _coverController = TextEditingController();

  Duration? _audioDuration;
  bool _isLoadingDuration = false;
  bool _isSaving = false;
  String? _durationError;

  @override
  void initState() {
    super.initState();
    _initializeSoloud();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  Future<void> _initializeSoloud() async {
    await _soloud.init();
  }

  Future<void> _pickAudioFile() async {
    final l = AppLocalizations.of(context)!;

    if (Platform.isAndroid) {
      if (!await Permission.storage.status.isGranted) {
        await Permission.storage.request();
      }
      if (!await Permission.manageExternalStorage.status.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["wav"],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.single.path!);

      setState(() {
        _audioFile = file;
        _audioDuration = null;
        _durationError = null;
        _isLoadingDuration = true;
      });

      try {
        final audioSource = await _soloud.loadFile(file.path);
        setState(() {
          _audioDuration = _soloud.getLength(audioSource);
          _isLoadingDuration = false;
        });
      } catch (e) {
        setState(() {
          _durationError = l.metadata_duration_error(e.toString());
          _isLoadingDuration = false;
        });
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: l.metadata_select_date,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: DefaultColors.func,
              onPrimary: DefaultColors.bg,
              surface: DefaultColors.bg,
              onSurface: DefaultColors.fg,
            ),
            dialogTheme: DialogThemeData(backgroundColor: DefaultColors.bg),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    if (context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: l.metadata_select_time,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: DefaultColors.func,
                onPrimary: DefaultColors.bg,
                surface: DefaultColors.bg,
                onSurface: DefaultColors.fg,
              ),
              dialogTheme: DialogThemeData(backgroundColor: DefaultColors.bg),
            ),
            child: child!,
          );
        },
      );

      if (time == null) return;

      setState(() {
        _selectedDate = date;
        _selectedTime = time;
      });
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: DefaultColors.bg,
      title: Text(
        l.metadata_title,
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
              // 音频文件选择
              ElevatedButton.icon(
                icon: Icon(
                  Icons.audio_file,
                  color: DefaultColors.fg,
                  size: 4.em,
                ),
                label: Text(
                  l.metadata_select_file,
                  style: TextStyle(fontSize: 3.5.em, fontFamily: "朱雀仿宋"),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.shade_2,
                  foregroundColor: DefaultColors.fg,
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.em,
                    vertical: 2.em,
                  ),
                ),
                onPressed: _pickAudioFile,
              ),
              SizedBox(height: 2.em),
              Text(
                _audioFile?.path ?? l.metadata_no_file_selected,
                style: TextStyle(
                  color: DefaultColors.shade_5,
                  fontSize: 3.em,
                  fontFamily: "朱雀仿宋",
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // 音频时长显示
              if (_isLoadingDuration)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.em),
                  child: Spinner(Icons.sync, DefaultColors.keyword, 2.5.em),
                )
              else if (_audioDuration != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.em),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, size: 4.em, color: DefaultColors.info),
                      SizedBox(width: 1.em),
                      Text(
                        '${l.metadata_duration}: ${_formatDuration(_audioDuration!)}',
                        style: TextStyle(
                          color: DefaultColors.fg,
                          fontSize: 3.5.em,
                          fontFamily: "朱雀仿宋",
                        ),
                      ),
                    ],
                  ),
                )
              else if (_durationError != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.em),
                  child: Text(
                    _durationError!,
                    style: TextStyle(
                      color: DefaultColors.error,
                      fontSize: 3.5.em,
                      fontFamily: "朱雀仿宋",
                    ),
                  ),
                ),

              Divider(height: 6.em, color: DefaultColors.shade_3),
              // 日期时间选择器
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _selectedDate == null || _selectedTime == null
                      ? l.metadata_select_datetime
                      : DateFormat.yMd().add_jm().format(
                          DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            _selectedTime!.hour,
                            _selectedTime!.minute,
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
                onTap: () => _selectDateTime(context),
              ),

              // 标题输入
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration(
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
              // 经纬度输入
              Text(
                l.metadata_location_optional,
                style: TextStyle(
                  color: DefaultColors.fg,
                  fontWeight: FontWeight.bold,
                  fontSize: 3.5.em,
                  fontFamily: "朱雀仿宋",
                ),
              ),
              SizedBox(height: 2.em),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: DefaultColors.func,
                      controller: _latController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _buildInputDecoration(
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
                  SizedBox(width: 2.em),
                  Expanded(
                    child: TextFormField(
                      cursorColor: DefaultColors.func,
                      controller: _lonController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _buildInputDecoration(
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
              // 封面emoji输入
              TextFormField(
                cursorColor: DefaultColors.func,
                controller: _coverController,
                decoration: _buildInputDecoration(
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
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(
            l.metadata_cancel,
            style: TextStyle(
              color: DefaultColors.error,
              fontSize: 3.5.em,
              fontFamily: "朱雀仿宋",
            ),
          ),
        ),
        _isSaving
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.em),
                child: Spinner(Icons.sync, DefaultColors.func, 4.em),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DefaultColors.func,
                  foregroundColor: DefaultColors.bg,
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.em,
                    vertical: 2.em,
                  ),
                ),
                onPressed: (_selectedDate != null && _audioFile != null)
                    ? _saveMetadata
                    : () {},
                child: Text(
                  l.metadata_import,
                  style: TextStyle(fontSize: 3.5.em, fontFamily: "朱雀仿宋"),
                ),
              ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String labelText, String? hintText) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(
        color: DefaultColors.shade_5,
        fontSize: 3.5.em,
        fontFamily: "朱雀仿宋",
      ),
      floatingLabelStyle: TextStyle(
        color: DefaultColors.func,
        fontSize: 3.5.em,
        fontFamily: "朱雀仿宋",
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.shade_4, width: 0.25.em),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.shade_4, width: 0.25.em),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.func, width: 0.5.em),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.error, width: 0.25.em),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: DefaultColors.error, width: 0.5.em),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 3.em, vertical: 4.em),
    );
  }

  Future<void> _saveMetadata() async {
    if (!_formKey.currentState!.validate() ||
        _audioFile == null ||
        _audioDuration == null) {
      return;
    }

    setState(() => _isSaving = true);

    var timestamp = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final settings = await ss.read(key: ss.TTS_MODEL_SETTINGS);
    final model = settings == null ? null : TtsSetting.fromJson(settings).model;
    final metadata = await compute(_import, {
      'model': model,
      'file': _audioFile!,
      'enc': Encryption.instance,
      'base_path': IO.STORAGE,
      'md': Metadata(
        time: timestamp,
        length: _audioDuration!,
        title: _titleController.text,
        latitude: _latController.text.isNotEmpty
            ? double.parse(_latController.text)
            : 0.0,
        longitude: _lonController.text.isNotEmpty
            ? double.parse(_lonController.text)
            : 0.0,
        cover: _coverController.text,
        path: (timestamp.toString() + DateTime.now().toString()).hashCode
            .toString(),
        transcript: '',
      ).dyn,
    });

    IO.addEntry(metadata);
    await IO.updateIndexOnDisk();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  static Future<Metadata> _import(Map<String, dynamic> params) async {
    final file = params['file'] as File;
    final md = params['md'];
    Encryption.initByInstance(params['enc']);
    IO.STORAGE = params['base_path'];

    final wav = await Wav.readFile(file.path);
    md["transcript"] = await Tts.fromWAV(
      params['model'] as so.OnlineModelConfig,
      Float32List.fromList(wav.channels.first.toList()),
      wav.samplesPerSecond,
    );
    print("transcript:");
    print(md["transcript"]);
    print("EOF");

    final metadata = Metadata.fromDyn(md);
    await IO.save(await file.readAsBytes(), metadata);
    return metadata;
  }
}

Future<void> showMetadataInputDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (context) => const MetadataInputDialog(),
  );
}
