import 'package:flutter/material.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/components/style/settings.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/services/secure_storage.dart' as ss;
import 'package:jiyi/utils/data/geo_setting.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:jiyi/utils/anno.dart';

@Claude()
class GeoSettings extends StatefulWidget {
  final AppLocalizations loc;
  const GeoSettings(this.loc, {super.key});

  @override
  State<GeoSettings> createState() => _GeoSettingsState();
}

class _GeoSettingsState extends State<GeoSettings> {
  late final AppLocalizations l;
  late GeoSetting _setting;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    l = widget.loc;
    _setting = GeoSetting();
    _loadGeoSettings();
  }

  Future<void> _loadGeoSettings() async {
    final settings = await ss.read(key: ss.GEO_SETTINGS);
    if (settings != null) {
      setState(() => _setting = GeoSetting.fromJson(settings));
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
              l.settings_geo,
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Settings.settingOpButton(() async {
                  await ss.write(key: ss.GEO_SETTINGS, value: null);
                  setState(() => _setting = GeoSetting());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.settings_geo_reset)),
                    );
                  }
                }, Icons.undo),
                Settings.settingOpButton(() async {
                  await ss.write(
                    key: ss.GEO_SETTINGS,
                    value: _setting.toJson(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l.settings_geo_saved)),
                    );
                  }
                }, Icons.save),
              ],
            ),
          ],
        ),
        Settings.flex(
          children: [
            Text(l.settings_geo_desc),
            Switch(
              value: _setting.enabled,
              onChanged: (value) async {
                setState(() => _setting.enabled = value);
              },
              activeTrackColor: DefaultColors.keyword,
              inactiveTrackColor: DefaultColors.shade_2,
              activeThumbColor: DefaultColors.fg,
              inactiveThumbColor: DefaultColors.shade_5,
            ),
          ],
        ),
        if (_setting.enabled) ...[
          Wrap(
            children: [
              Settings.buildFileChooser(
                () => _download(
                  "https://codeberg.org/xiaoshihou/geojson/media/branch/main/",
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
              Settings.buildFileChooser(
                () => _download(
                  "https://gitlab.com/xiaoshihou/geojson/-/raw/main/",
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
              Settings.buildFileChooser(
                () => _download(
                  "https://github.com/xiaoshihou514/geojson/raw/refs/heads/main/",
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
      ],
    );
  }

  Future<void> _download(String prefix) async {
    if (_isDownloading || !mounted) return;

    setState(() => _isDownloading = true);

    try {
      final dest = (await getApplicationSupportDirectory()).path;
      final geoDir = path.join(dest, 'geojson');

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) =>
            DownloadUnzipDialog(urls: ["${prefix}all.zip"], dest: geoDir),
      );

      if (!mounted) return;

      setState(() {
        _setting.dataPath = geoDir;
        _isDownloading = false;
      });

      // Auto-save after successful download
      await ss.write(key: ss.GEO_SETTINGS, value: _setting.toJson());
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }
}
