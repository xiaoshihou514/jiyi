// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
      time: DateTime.parse(json['time'] as String),
      length: Duration(microseconds: (json['length'] as num).toInt()),
      title: json['title'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cover: json['cover'] as String,
      path: json['path'] as String,
      transcript: json['transcript'] as String,
    );

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'length': instance.length.inMicroseconds,
      'title': instance.title,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'cover': instance.cover,
      'path': instance.path,
      'transcript': instance.transcript,
    };
