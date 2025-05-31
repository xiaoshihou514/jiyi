// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
      timestamp: DateTime.parse(json['timestamp'] as String),
      length: Duration(microseconds: (json['length'] as num).toInt()),
      title: json['title'] as String?,
    );

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'length': instance.length.inMicroseconds,
      'title': instance.title,
    };
