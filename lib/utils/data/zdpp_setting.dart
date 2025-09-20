import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

part "zdpp_setting.g.dart";

@JsonSerializable(includeIfNull: false)
class ZdppSetting {
  String? name;
  String path;

  ZdppSetting({this.name, required this.path});

  factory ZdppSetting.fromDyn(Map<String, dynamic> dyn) =>
      _$ZdppSettingFromJson(dyn);
  factory ZdppSetting.fromJson(String json) =>
      _$ZdppSettingFromJson(jsonDecode(json));
  Map<String, dynamic> get dyn => _$ZdppSettingToJson(this);

  String get json => jsonEncode(dyn);
  so.OfflinePunctuationConfig get model => so.OfflinePunctuationConfig(
    model: so.OfflinePunctuationModelConfig(ctTransformer: path, numThreads: 4),
  );
}
