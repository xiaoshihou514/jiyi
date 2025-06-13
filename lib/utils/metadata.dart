import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

part "metadata.g.dart";

@JsonSerializable()
class Metadata {
  final DateTime time;
  final Duration length;
  final String title;
  final double latitude;
  final double longitude;
  // length = 1 emoji
  final String cover;
  final String path;
  // TODO: not used
  final String transcript;

  Metadata({
    required this.time,
    required this.length,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.cover,
    required this.path,
    required this.transcript,
  });

  factory Metadata.fromDyn(Map<String, dynamic> dyn) => _$MetadataFromJson(dyn);
  Map<String, dynamic> get dyn => _$MetadataToJson(this);
  String get json => jsonEncode(dyn);
  LatLng get pt => LatLng(latitude, longitude);

  @override
  String toString() => json;
}
