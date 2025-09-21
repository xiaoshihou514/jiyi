// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/components/yes_no.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/utils/data/llm_setting.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const GEO_DATA = "cities15000.txt";

class Imagine extends StatefulWidget {
  const Imagine({super.key});

  @override
  State<Imagine> createState() => _ImagineState();
}

class _ImagineState extends State<Imagine> {
  LLMSetting? _llmSetting;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ss.read(key: ss.LLM_MODEL_SETTINGS);
    setState(() => _llmSetting = LLMSetting.fromJson(settings!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

// maybe popup and ask permission for download
Future<bool> maybeDownloadGeoData(BuildContext context) async {
  final l = AppLocalizations.of(context)!;
  final dest = (await getApplicationSupportDirectory()).path;

  if (await ss.read(key: ss.LLM_MODEL_SETTINGS) == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.missing_llm_settings),
          duration: Duration(seconds: 5),
        ),
      );
    }
    return false;
  }

  if (!File(path.join(dest, GEO_DATA)).existsSync() && context.mounted) {
    final perm = await showYesNoDialog(
      context,
      l.imagine_download_geo_desc,
      l.imagine_download_geo_no,
      l.imagine_download_geo_yes,
    );

    if (perm && context.mounted) {
      // download
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DownloadUnzipDialog(
          urls: ["https://download.geonames.org/export/dump/cities15000.zip"],
          dest: dest,
        ),
      );

      return true;
    }

    return false;
  } else {
    return true;
  }
}
