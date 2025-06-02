import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/components/download.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/map_setting.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;

extension on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? sh / 128
      : sw / 96;
}

bool isMobile = ScreenUtil().screenWidth < ScreenUtil().screenHeight;
Widget _smartRow({required List<Widget> children}) => isMobile
    ? Wrap(children: children)
    : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      );

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return DefaultTextStyle.merge(
      style: TextStyle(
        decoration: TextDecoration.none,
        color: DefaultColors.fg,
        fontFamily: "朱雀仿宋",
        fontSize: 5.em,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8.em),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 3.em,
          children: [
            MapSettings(l),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.settings_reset,
                  style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
                ),
                Container(),
              ],
            ),
            _buildDangerSetting(
              l.settings_reset_mk_desc,
              l.settings_reset_mk,
              () => _resetMasterKey(context),
            ),
            _buildDangerSetting(
              l.settings_reset_spath_desc,
              l.settings_reset_spath,
              () => _resetStoragePath(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerSetting(String desc, String btn, void Function() action) {
    return _smartRow(
      children: [
        Text(desc),
        TextButton(
          onPressed: action,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? DefaultColors.bg
                  : DefaultColors.error,
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
                side: BorderSide(color: DefaultColors.error),
              ),
            ),
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.pressed)
                  ? DefaultColors.error
                  : DefaultColors.bg,
            ),
            textStyle: WidgetStateProperty.all(
              TextStyle(
                decoration: TextDecoration.none,
                fontFamily: "朱雀仿宋",
                fontSize: 5.em,
              ),
            ),
          ),
          child: Padding(padding: EdgeInsets.all(1.em), child: Text(btn)),
        ),
      ],
    );
  }

  Future<void> _resetMasterKey(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    await ss.delete(key: ss.MASTER_KEY);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settings_reset_success)));
    }
  }

  Future<void> _resetStoragePath(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    await ss.delete(key: ss.STORAGE_PATH);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settings_reset_success)));
    }
  }
}

class MapSettings extends StatefulWidget {
  final AppLocalizations loc;
  const MapSettings(this.loc, {super.key});

  @override
  State<MapSettings> createState() => _MapSettingsState();
}

class _MapSettingsState extends State<MapSettings> {
  late List<String> list;
  late final AppLocalizations l;
  late MapSetting _setting;

  // local map provider related state
  final _localPatternController = TextEditingController();
  bool _custom = false;

  @override
  void initState() {
    super.initState();
    l = widget.loc;
    list = [
      l.settings_map_local,
      l.settings_map_osm,
      l.settings_map_amap,
      l.settings_map_amap_satelite,
      l.settings_map_other,
    ];
    _setting = MapSetting.local(l);
    _initMapSettings();
  }

  Future<void> _initMapSettings() async {
    final settings = await ss.read(key: ss.MAP_SETTINGS);
    if (settings != null) {
      setState(() {
        _setting = MapSetting.fromJson(settings);
        _localPatternController.text = _setting.pattern ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.settings_map,
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () async {
                _setting.pattern = _localPatternController.text;
                if (!_setting.isLocal ||
                    ((_setting.path ?? "").isNotEmpty &&
                        (_setting.pattern ?? "").isNotEmpty)) {
                  _setting.urlFmt = _setting.isLocal
                      ? path.join(_setting.path!, _setting.pattern!)
                      : _setting.urlFmt;
                  await ss.write(
                    key: ss.MAP_SETTINGS,
                    value: _setting.toJson(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.settings_map_save_success)),
                    );
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.settings_map_loc_missing_field)),
                  );
                }
              },
              iconSize: 6.em,
              alignment: Alignment.center,
              icon: Container(
                decoration: BoxDecoration(
                  color: DefaultColors.info,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.em,
                    vertical: 1.em,
                  ),
                  child: Icon(Icons.save, color: DefaultColors.bg),
                ),
              ),
            ),
          ],
        ),
        _smartRow(
          children: [
            Text(l.settings_map_provider),
            DropdownButton(
              value: _setting.name,
              icon: Icon(Icons.arrow_drop_down, size: 5.em),
              style: TextStyle(
                color: DefaultColors.fg,
                fontSize: 5.em,
                decoration: TextDecoration.none,
                fontFamily: "朱雀仿宋",
              ),
              dropdownColor: DefaultColors.shade_3,
              underline: Container(
                height: 1.5,
                width: 1.2,
                color: DefaultColors.fg,
              ),
              onChanged: (String? value) => setState(() {
                _setting.name = value!;
                if (_setting.name == l.settings_map_local) {
                  _setting.isLocal = true;
                  _setting.useInversionFilter = true;
                } else if (_setting.name == l.settings_map_custom) {
                  _custom = true;
                } else {
                  _usePreset(_setting.name);
                }
              }),
              items: list
                  .map(
                    (String value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
            ),
          ],
        ),

        if (_setting.name == l.settings_map_local)
          _localProviderSettings()
        else if (_custom)
          _networkProviderSettings()
        else
          Container(),

        Wrap(children: [Container()]),
      ],
    );
  }

  Widget _networkProviderSettings() {
    return Placeholder();
  }

  Widget _localProviderSettings() {
    return Column(
      children: [
        _smartRow(
          children: [
            Text(l.settings_map_loc_path),
            _buildRichButton(
              _choose,
              Icons.folder_open,
              (_setting.path ?? "").isEmpty
                  ? Text(
                      l.st_hint,
                      style: TextStyle(
                        fontSize: 5.em,
                        color: DefaultColors.bg,
                        fontFamily: "朱雀仿宋",
                      ),
                    )
                  : Text(
                      _setting.path!,
                      style: TextStyle(
                        fontSize: 3.em,
                        color: DefaultColors.bg,
                        fontFamily: "朱雀仿宋",
                      ),
                    ),
              DefaultColors.constant,
            ),
          ],
        ),
        _smartRow(
          children: [
            Text(l.settings_map_loc_pattern),
            SizedBox(
              height: 6.em,
              width: 50.em,
              child: Theme(
                data: Theme.of(context).copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    selectionColor: DefaultColors.shade_3,
                    selectionHandleColor: DefaultColors.shade_4,
                  ),
                ),
                child: TextField(
                  controller: _localPatternController,
                  style: TextStyle(
                    color: DefaultColors.fg,
                    fontSize: isMobile ? 4.em : 3.em,
                  ),
                  cursorColor: DefaultColors.shade_6,
                  decoration: InputDecoration(
                    contentPadding: isMobile
                        ? null
                        : EdgeInsets.symmetric(vertical: 1.em),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: DefaultColors.fg),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: DefaultColors.fg),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.settings_map_max_zoom),
            NumberPicker(
              textStyle: TextStyle(
                decoration: TextDecoration.none,
                color: DefaultColors.shade_4,
                fontFamily: "朱雀仿宋",
                fontSize: 5.em,
              ),
              selectedTextStyle: TextStyle(color: DefaultColors.fg),
              value: _setting.maxZoom,
              minValue: 4,
              maxValue: 20,
              onChanged: (value) => setState(() => _setting.maxZoom = value),
            ),
          ],
        ),
        Wrap(children: [Text(l.settings_map_pull_desc), Container()]),
        Wrap(
          children: [
            _buildRichButton(
              () => _download(
                "https://codeberg.org/xiaoshihou/openstreetmap_raw_raster_tiles_download_2025_5/media/branch/main/",
              ),
              Icons.download,
              Text(
                l.settings_map_loc_down_src("Codeberg"),
                style: TextStyle(
                  fontSize: 5.em,
                  color: DefaultColors.bg,
                  fontFamily: "朱雀仿宋",
                ),
              ),
              DefaultColors.keyword,
            ),
            _buildRichButton(
              () => _download(
                "https://gitlab.com/xiaoshihou/openstreetmap_raw_raster_tiles_download_2025_5/-/raw/main/",
              ),
              Icons.download,
              Text(
                l.settings_map_loc_down_src("Gitlab"),
                style: TextStyle(
                  fontSize: 5.em,
                  color: DefaultColors.bg,
                  fontFamily: "朱雀仿宋",
                ),
              ),
              DefaultColors.keyword,
            ),
            _buildRichButton(
              () => _download(
                "https://github.com/xiaoshihou514/openstreetmap_raw_raster_tiles_download_2025_5/raw/refs/heads/main/",
              ),
              Icons.download,
              Text(
                l.settings_map_loc_down_src("Github"),
                style: TextStyle(
                  fontSize: 5.em,
                  color: DefaultColors.bg,
                  fontFamily: "朱雀仿宋",
                ),
              ),
              DefaultColors.keyword,
            ),
          ],
        ),
      ],
    );
  }

  IconButton _buildRichButton(
    void Function() callback,
    IconData icon,
    Text text,
    Color bg,
  ) {
    return IconButton(
      onPressed: callback,
      iconSize: 6.em,
      alignment: Alignment.center,
      icon: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.em, vertical: 1.em),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 3.em,
            children: [
              Icon(icon, color: DefaultColors.bg),
              text,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _choose() async {
    if (!Platform.isLinux) {
      if (!await Permission.storage.status.isGranted) {
        await Permission.storage.request();
      }
      if (!await Permission.manageExternalStorage.status.isGranted) {
        await Permission.manageExternalStorage.request();
      }
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
      lockParentWindow: true,
    );

    if (selectedDirectory != null) {
      setState(() {
        _setting.urlFmt = path.join(
          selectedDirectory,
          _localPatternController.text,
        );
        _setting.path = selectedDirectory;
      });
    }
  }

  void _usePreset(String name) {
    if (name == l.settings_map_osm) {
      _setting = MapSetting(
        isLocal: false,
        isOSM: true,
        urlFmt: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
        name: l.settings_map_osm,
        maxZoom: 16,
      );
    } else if (name == l.settings_map_amap) {
      _setting = MapSetting(
        isLocal: false,
        isOSM: false,
        urlFmt:
            'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=2&style=8&x={x}&y={y}&z={z}',
        subdomains: ["1", "2", "3", "4"],
        name: l.settings_map_amap,
        maxZoom: 18,
      );
    } else if (name == l.settings_map_amap_satelite) {
      _setting = MapSetting(
        isLocal: false,
        isOSM: false,
        urlFmt:
            'https://webst0{s}.is.autonavi.com/appmaptile?style=6&x={x}&y={y}&z={z}',
        subdomains: ["1", "2", "3", "4"],
        name: l.settings_map_amap_satelite,
        maxZoom: 18,
        useInversionFilter: false,
      );
    }
  }

  void _download(String prefix) {
    if ((_setting.path ?? "").isNotEmpty) {
      showDownloadDialog(context, prefix, _setting.path!, _setting.maxZoom);
    } else if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.settings_map_loc_missing_field)));
    }
  }
}
