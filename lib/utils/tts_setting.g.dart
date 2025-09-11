// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tts_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TtsSetting _$TtsSettingFromJson(Map<String, dynamic> json) => TtsSetting(
  encoder: json['encoder'] as String,
  decoder: json['decoder'] as String,
  joiner: json['joiner'] as String,
  tokens: json['tokens'] as String,
  modelType: json['modelType'] as String,
  name: json['name'] as String?,
);

Map<String, dynamic> _$TtsSettingToJson(TtsSetting instance) =>
    <String, dynamic>{
      'encoder': instance.encoder,
      'decoder': instance.decoder,
      'joiner': instance.joiner,
      'tokens': instance.tokens,
      'modelType': instance.modelType,
      'name': ?instance.name,
    };
