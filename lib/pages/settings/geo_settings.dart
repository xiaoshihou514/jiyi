import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/components/style/settings.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/services/geo.dart';
import 'package:jiyi/services/io.dart' as app_io;
import 'package:jiyi/services/secure_storage.dart' as ss;
import 'package:jiyi/utils/data/geo_setting.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:jiyi/utils/notifier.dart';

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
              style: TextStyle(fontSize: 8.em, fontWeight: FontWeight.bold, fontFamily: "朱雀仿宋"),
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
              ],
            ),
          ],
        ),
        Settings.flex(
          children: [
            Text(l.settings_geo_desc, style: TextStyle(fontFamily: "朱雀仿宋")),
            Settings.settingSwitch(
              value: _setting.enabled,
              onChanged: (value) async {
                setState(() => _setting.enabled = value);
                await ss.write(key: ss.GEO_SETTINGS, value: _setting.toJson());
              },
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
          SizedBox(height: 2.em),
          Settings.buildFileChooser(
            _showBulkGenerateDialog,
            Icons.location_searching,
            Text(
              l.settings_geo_bulk_generate,
              style: TextStyle(
                fontSize: 5.em,
                color: DefaultColors.bg,
                fontFamily: "朱雀仿宋",
              ),
            ),
            DefaultColors.special,
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

      if (!Directory(geoDir).existsSync()) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) =>
              DownloadUnzipDialog(urls: ["${prefix}all.zip"], dest: geoDir),
        );
      }

      setState(() {
        _setting.dataPath = geoDir;
        _isDownloading = false;
      });

      // Auto-save after successful download
      await ss.write(key: ss.GEO_SETTINGS, value: _setting.toJson());
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.geo_download_failed(e.toString()))),
      );
    }
  }
  
  Future<void> _showBulkGenerateDialog() async {
    if (!mounted) return;
    
    // Count recordings without geodesc
    final allRecordings = await app_io.IO.indexFuture;
    final withoutGeoDesc = allRecordings
        .where((r) => r.hasGeo && (r.geodesc == null || r.geodesc!.isEmpty))
        .toList();
    
    if (withoutGeoDesc.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.settings_geo_bulk_no_recordings)),
      );
      return;
    }
    
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DefaultColors.shade_1,
        title: Text(
          l.settings_geo_bulk_generate_title,
          style: TextStyle(color: DefaultColors.fg, fontFamily: "朱雀仿宋"),
        ),
        content: Text(
          l.settings_geo_bulk_generate_message(withoutGeoDesc.length),
          style: TextStyle(color: DefaultColors.shade_5, fontFamily: "朱雀仿宋"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l.settings_geo_bulk_cancel,
              style: TextStyle(color: DefaultColors.shade_5, fontFamily: "朱雀仿宋"),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l.settings_geo_bulk_confirm,
              style: TextStyle(color: DefaultColors.keyword, fontFamily: "朱雀仿宋"),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed != true || !mounted) return;
    
    // Show progress dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: DefaultColors.shade_1,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: DefaultColors.keyword),
            SizedBox(height: 2.em),
            Text(
              l.settings_geo_bulk_processing,
              style: TextStyle(color: DefaultColors.fg, fontFamily: "朱雀仿宋"),
            ),
          ],
        ),
      ),
    );
    
    // Process recordings
    final geo = Geo();
    int successCount = 0;
    
    for (final recording in withoutGeoDesc) {
      if (recording.latitude != null && recording.longitude != null) {
        try {
          final geodesc = await geo.getLocationDescription(
            recording.latitude!,
            recording.longitude!,
          );
          
          if (geodesc != null && geodesc.isNotEmpty) {
            final updated = Metadata(
              time: recording.time,
              length: recording.length,
              title: recording.title,
              latitude: recording.latitude,
              longitude: recording.longitude,
              cover: recording.cover,
              path: recording.path,
              transcript: recording.transcript,
              geodesc: geodesc,
            );
            
            await app_io.IO.updateMetadata(recording, updated);
            successCount++;
          }
        } catch (e) {
          // Skip failed lookups
          continue;
        }
      }
    }
    
    // Trigger notifier to refresh UI
    if (mounted) {
      Provider.of<Notifier>(context, listen: false).trigger();
    }
    
    // Close progress dialog
    if (mounted) {
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.settings_geo_bulk_complete(successCount, withoutGeoDesc.length)),
        ),
      );
    }
  }
}
