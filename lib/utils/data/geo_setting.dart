import 'dart:convert';
import 'package:jiyi/utils/anno.dart';
import 'package:json_annotation/json_annotation.dart';

part 'geo_setting.g.dart';

@Claude()
@JsonSerializable()
class GeoSetting {
  bool enabled;
  String? dataPath;

  GeoSetting({
    this.enabled = false,
    this.dataPath,
  });

  factory GeoSetting.fromJson(String json) =>
      _$GeoSettingFromJson(jsonDecode(json));

  String toJson() => jsonEncode(_$GeoSettingToJson(this));
}
