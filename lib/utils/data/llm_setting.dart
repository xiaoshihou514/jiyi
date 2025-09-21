import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part "llm_setting.g.dart";

@JsonSerializable(includeIfNull: false)
class LLMSetting {
  String rootPath;
  String imaginePrompt;
  String? name;

  LLMSetting({required this.rootPath, required this.imaginePrompt, this.name});

  String get json => jsonEncode(dyn);
  Map<String, dynamic> get dyn => _$LLMSettingToJson(this);
  factory LLMSetting.fromJson(String json) =>
      _$LLMSettingFromJson(jsonDecode(json));
}
