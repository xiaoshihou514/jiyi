// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/components/yes_no.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/utils/data/llm_setting.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/llm.dart';
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
  late LLMSetting _llmSetting;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ss.read(key: ss.LLM_MODEL_SETTINGS);
    setState(() => _llmSetting = LLMSetting.fromJson(settings!));
    testLLM();
  }

  static Future<void> testLLM() async {
    final mds = await IO.indexFuture;

    for (final md in mds) {
      final ts = md.time;
      final now = DateTime.now().toLocal();
      final input = "${ts.year}年${ts.month}月${ts.day}日录制于上海：${md.transcript}";
      final x = await Llm.imagine(
        LLMSetting(
          rootPath:
              "/home/xiaoshihou/.local/share/com.github.xiaoshihou.jiyi/千问3-1.7B",
          name: "千问3-1.7B",
          imaginePrompt:
              """
分析语音转录文本，判断用户是否可能愿意追加录音分享后续。核心原则是区分内容的封闭性和开放性。封闭性内容（如日常琐事、已结束的事件）权重低（0.1-0.3）。开放性内容（如未完成的目标、计划、问题或承诺）权重高（0.7-0.9）。绝大多数录音内容琐碎，不值得追问，只有少数有明显延续性的话题才值得追问。
请理解转录文本可能存在错别字或语句不通，需推断核心意图。如果值得追问，生成的追问必须非常简短，并提及录音中的具体内容，礼貌地询问进展或后续。
输出格式必须严格为： 权重数值|一句简短的追问
如果内容完全不值得追问，不要有任何输出

时间是${now.year}年${now.month}月${now.day}日
""",
        ),
        input,
      );
      print("resp: '$x'");
    }
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
