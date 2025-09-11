import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

part "tts_setting.g.dart";

@JsonSerializable(includeIfNull: false)
class TtsSetting {
  String encoder;
  String decoder;
  String joiner;
  String tokens;
  String modelType;
  String? name;

  TtsSetting({
    required this.encoder,
    required this.decoder,
    required this.joiner,
    required this.tokens,
    required this.modelType,
    this.name,
  });

  factory TtsSetting.fromDyn(Map<String, dynamic> dyn) =>
      _$TtsSettingFromJson(dyn);
  factory TtsSetting.fromJson(String json) =>
      _$TtsSettingFromJson(jsonDecode(json));
  Map<String, dynamic> get dyn => _$TtsSettingToJson(this);
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
