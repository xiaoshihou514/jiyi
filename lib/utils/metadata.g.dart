// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metadata.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metadata _$MetadataFromJson(Map<String, dynamic> json) => Metadata(
      time: DateTime.parse(json['time'] as String),
      length: Duration(microseconds: (json['length'] as num).toInt()),
      title: json['title'] as String,
      coord: LatLng.fromJson(json['coord'] as Map<String, dynamic>),
      transcript: json['transcript'] as String,
    );

Map<String, dynamic> _$MetadataToJson(Metadata instance) => <String, dynamic>{
      'time': instance.time.toIso8601String(),
      'length': instance.length.inMicroseconds,
      'title': instance.title,
      'coord': instance.coord,
      'transcript': instance.transcript,
    };
