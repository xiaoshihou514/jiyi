// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoder_offline/geocoder_offline.dart';
import 'package:jiyi/components/download_unzip.dart';
import 'package:jiyi/components/yes_no.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/utils/data/llm_setting.dart';
import 'package:jiyi/utils/geocoder.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/llm.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const GEO_DATA = "cities15000.txt";
const HEADERS =
    "geonameid\tname\tasciiname\talternatenames\tlatitude\tlongitude\tfeature class\tfeature code\tcountry code\tcc2\tadmin1 code\tadmin2 code\tadmin3 code\tadmin4 code\tpopulation\televation\tdem\ttimezone\tmodification date\n";

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
    if (mounted) {
      testLLM(context);
    }
  }

  static Future<void> testLLM(BuildContext context) async {
    final l = AppLocalizations.of(context)!;
    final mds = await IO.indexFuture;
    final dest = (await getApplicationSupportDirectory()).path;
    final geocoder = GeocodeData(
      HEADERS + File(path.join(dest, GEO_DATA)).readAsStringSync(),
      'alternatenames',
      'name',
      'latitude',
      'longitude',
      fieldDelimiter: '\t',
      eol: '\n',
    );

    for (final md in mds) {
      final ts = md.time;
      final now = DateTime.now().toLocal();

      var place =
          Geocoder.placeOf(geocoder, md, l.localeName) ??
          l.imagine_unknown_place;

      print(place);
      final input =
          "${ts.year}年${ts.month}月${ts.day}日录制于$place：${md.transcript}";
      final x = await Llm.imagine(
        LLMSetting(
          rootPath:
              "/home/xiaoshihou/.local/share/com.github.xiaoshihou.jiyi/千问3-1.7B",
          name: "千问3-1.7B",
          imaginePrompt:
              """
你是一个对话分析专家。请根据以下规则处理用户的语音转录文本。
第一步：内容评估（决定权重）
根据以下特征为文本的"可追问性"打分（0-1）：
- 高权重：表达未解决的困扰、强烈的情感、重要的个人决策、深入的价值观反思
- 中权重：提到未完成的计划或项目，但缺乏情感深度或具体细节
- 低权重：关于已完成的日常琐事、单纯的事实陈述，无讨论空间
第二步：生成追问
如果值得追问，请生成一句追问。追问必须：
1. 紧扣文本：明确引用用户提到的具体点
2. 开放且有深度：引导分享思考过程、情感体验
3. 避免：是/否问题、单纯询问"进展如何"
输出格式必须严格为：权重数值|生成的追问
当前时间：${now.year}年${now.month}月${now.day}日
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
