import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

part "asr_setting.g.dart";

@JsonSerializable(includeIfNull: false)
class AsrSetting {
  String? encoder;
  String? decoder;
  String? joiner;
  String? single;
  String tokens;
  String modelType;
  String? name;

  AsrSetting({
    this.encoder,
    this.decoder,
    this.joiner,
    this.single,
    required this.tokens,
    required this.modelType,
    this.name,
  });

  factory AsrSetting.fromDyn(Map<String, dynamic> dyn) =>
      _$AsrSettingFromJson(dyn);
  factory AsrSetting.fromJson(String json) =>
      _$AsrSettingFromJson(jsonDecode(json));
  Map<String, dynamic> get dyn {
    final data = _$AsrSettingToJson(this);
    if (modelType == "transducer") {
      data["single"] = null;
    } else if (modelType == "paraformer") {
      data["single"] = null;
      data["joiner"] = null;
    } else if (modelType == "zipformer2Ctc") {
      data["decoder"] = null;
      data["encoder"] = null;
      data["joiner"] = null;
    } else if (modelType == "nemoCtc") {
      data["decoder"] = null;
      data["encoder"] = null;
      data["joiner"] = null;
    } else if (modelType == "toneCtc") {
      data["decoder"] = null;
      data["encoder"] = null;
      data["joiner"] = null;
    }
    return data;
  }

  String get json => jsonEncode(dyn);
  so.OnlineModelConfig get model {
    if (modelType == "transducer") {
      return so.OnlineModelConfig(
        numThreads: 4,
        tokens: tokens,
        transducer: so.OnlineTransducerModelConfig(
          encoder: encoder!,
          decoder: decoder!,
          joiner: joiner!,
        ),
      );
    } else if (modelType == "paraformer") {
      return so.OnlineModelConfig(
        numThreads: 4,
        tokens: tokens,
        paraformer: so.OnlineParaformerModelConfig(
          encoder: encoder!,
          decoder: decoder!,
        ),
      );
    } else if (modelType == "zipformer2Ctc") {
      return so.OnlineModelConfig(
        numThreads: 4,
        tokens: tokens,
        zipformer2Ctc: so.OnlineZipformer2CtcModelConfig(model: single!),
      );
    } else if (modelType == "nemoCtc") {
      return so.OnlineModelConfig(
        numThreads: 4,
        tokens: tokens,
        nemoCtc: so.OnlineNemoCtcModelConfig(model: single!),
      );
    } else if (modelType == "toneCtc") {
      return so.OnlineModelConfig(
        numThreads: 4,
        tokens: tokens,
        toneCtc: so.OnlineToneCtcModelConfig(model: single!),
      );
    } else {
      throw Exception("asr_setting: invalid");
    }
  }

  @override
  String toString() => json;
}
