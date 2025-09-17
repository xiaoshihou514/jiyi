import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

part "asr_setting.g.dart";

@JsonSerializable(includeIfNull: false)
class AsrSetting {
  String encoder;
  String decoder;
  String joiner;
  String tokens;
  String modelType;
  String? name;

  AsrSetting({
    required this.encoder,
    required this.decoder,
    required this.joiner,
    required this.tokens,
    required this.modelType,
    this.name,
  });

  factory AsrSetting.fromDyn(Map<String, dynamic> dyn) =>
      _$AsrSettingFromJson(dyn);
  factory AsrSetting.fromJson(String json) =>
      _$AsrSettingFromJson(jsonDecode(json));
  Map<String, dynamic> get dyn => _$AsrSettingToJson(this);
  String get json => jsonEncode(dyn);
  so.OnlineModelConfig get model => so.OnlineModelConfig(
    transducer: so.OnlineTransducerModelConfig(
      encoder: encoder,
      decoder: decoder,
      joiner: joiner,
    ),
    tokens: tokens,
    modelType: modelType,
  );

  @override
  String toString() => json;
}
