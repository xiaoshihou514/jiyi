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
  String? header;
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
    this.header,
    this.useInversionFilter = true,
  });

  factory MapSetting.fromJson(String json) =>
      _$MapSettingFromJson(jsonDecode(json));

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  String get json => jsonEncode(_dyn);
  Map<String, dynamic> get _dyn => _$MapSettingToJson(this);
  Map<String, dynamic> get dynCustomNetwork {
    Map<String, dynamic> s = {};
    s["isLocal"] = isLocal;
    s["isOSM"] = isOSM;
    s["urlFmt"] = urlFmt;
    s["name"] = name;
    s["maxZoom"] = maxZoom;
    s["useInversionFilter"] = false;
    s["subdomains"] = subdomains;
    s["header"] = header;
    return s;
  }

  Map<String, dynamic> get dynCustomLocal {
    Map<String, dynamic> s = {};
    s["isLocal"] = isLocal;
    s["isOSM"] = isOSM;
    s["urlFmt"] = urlFmt;
    s["name"] = name;
    s["maxZoom"] = maxZoom;
    s["useInversionFilter"] = useInversionFilter;
    s["path"] = path;
    s["pattern"] = pattern;
    return s;
  }

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
