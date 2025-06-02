import 'package:json_annotation/json_annotation.dart';
import 'package:latlong2/latlong.dart';

part "metadata.g.dart";

@JsonSerializable()
class Metadata {
  final DateTime time;
  final Duration length;
  final String title;
  final LatLng coord;
  // TODO
  final String transcript;

  Metadata({
    required this.time,
    required this.length,
    required this.title,
    required this.coord,
    required this.transcript,
  });
}
