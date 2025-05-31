import 'dart:convert';

import 'package:jiyi/l10n/localizations.dart';
import 'package:json_annotation/json_annotation.dart';

part 'map_setting.g.dart';

@JsonSerializable(includeIfNull: false)
class MapSetting {
  bool isLocal;
  bool isOSM;
  String urlFmt;
  String name;
  int maxZoom;
  bool useInversionFilter;
  // network specific
  List<String>? subdomains;
  //  local specific
  String? path;
  String? pattern;

  MapSetting({
    required this.isLocal,
    required this.isOSM,
    required this.urlFmt,
    required this.name,
    required this.maxZoom,
    this.path,
    this.pattern,
    this.subdomains,
    this.useInversionFilter = true,
  });

  factory MapSetting.fromJson(String json) =>
      _$MapSettingFromJson(jsonDecode(json));

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  String toJson() => jsonEncode(_$MapSettingToJson(this));

  factory MapSetting.local(AppLocalizations l) => MapSetting(
    isOSM: true,
    isLocal: true,
    urlFmt: './{z}/{x}-{y}.png',
    name: l.settings_map_local,
    maxZoom: 10,
    path: '',
    pattern: '{z}/{x}-{y}.png',
  );
}
