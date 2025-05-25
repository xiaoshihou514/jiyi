import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Metadata {
  final DateTime timestamp;
  final Duration length;
  final String? title;

  Metadata({
    required this.timestamp,
    required this.length,
    required this.title,
  });
}
