// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MapSetting _$MapSettingFromJson(Map<String, dynamic> json) => MapSetting(
  isLocal: json['isLocal'] as bool,
  isOSM: json['isOSM'] as bool,
  urlFmt: json['urlFmt'] as String,
  name: json['name'] as String,
  maxZoom: (json['maxZoom'] as num).toInt(),
  path: json['path'] as String?,
  pattern: json['pattern'] as String?,
  subdomains: (json['subdomains'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  header: json['header'] as String?,
  useInversionFilter: json['useInversionFilter'] as bool? ?? true,
);

Map<String, dynamic> _$MapSettingToJson(MapSetting instance) =>
    <String, dynamic>{
      'isLocal': instance.isLocal,
      'isOSM': instance.isOSM,
      'urlFmt': instance.urlFmt,
      'name': instance.name,
      'maxZoom': instance.maxZoom,
      'useInversionFilter': instance.useInversionFilter,
      'subdomains': ?instance.subdomains,
      'header': ?instance.header,
      'path': ?instance.path,
      'pattern': ?instance.pattern,
    };
