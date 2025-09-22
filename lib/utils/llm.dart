// ignore_for_file: non_constant_identifier_names

import 'package:jiyi/src/rust/api.dart' as api;
import 'package:jiyi/src/rust/frb_generated.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/data/llm_setting.dart';

abstract class Llm {
  static bool init = false;
  static final TRIM_PREFIX = ["\n", "\t", " ", "<think>", "</think>", "。", "，"];

  @DeepSeek()
  static String trim(String text) {
    if (text.isEmpty) {
      return text;
    }
    text = text.trim();

    // 去除开头的匹配模式
    int startIndex = 0;
    bool startFound = true;

    while (startFound && startIndex < text.length) {
      startFound = false;
      for (String pattern in TRIM_PREFIX) {
        if (pattern.isEmpty) continue;

        if (text.startsWith(pattern, startIndex)) {
          startIndex += pattern.length;
          startFound = true;
          break; // 找到一个匹配就跳出循环，重新检查
        }
      }
    }

    // 去除结尾的匹配模式
    int endIndex = text.length;
    bool endFound = true;

    while (endFound && endIndex > startIndex) {
      endFound = false;
      for (String pattern in TRIM_PREFIX) {
        if (pattern.isEmpty) continue;

        if (text.substring(0, endIndex).endsWith(pattern)) {
          endIndex -= pattern.length;
          endFound = true;
          break; // 找到一个匹配就跳出循环，重新检查
        }
      }
    }

    return text.substring(startIndex, endIndex);
  }

  static Future<String> prompt({
    required String root,
    required String system,
    required String input,
    required double temp,
    required double topP,
    required double repeatPenalty,
    required int repeatLastN,
  }) async {
    if (!init) {
      await RustLib.init();
      init = true;
    }
    return trim(
      api.prompt(
        root: root,
        system: system,
        prompt: input,
        temp: temp,
        topP: topP,
        repeatPenalty: repeatPenalty,
        repeatLastN: BigInt.from(repeatLastN),
      ),
    );
  }

  static Future<String> imagine(LLMSetting setting, String input) async =>
      prompt(
        root: setting.rootPath,
        system: setting.imaginePrompt,
        input: input,
        temp: 0.4,
        topP: 0.8,
        repeatPenalty: 1.2,
        repeatLastN: 32,
      );
}
