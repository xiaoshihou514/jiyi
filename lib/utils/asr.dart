import 'dart:typed_data';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/data/llm_setting.dart';
// import 'package:jiyi/src/rust/api.dart' as api;
// import 'package:jiyi/src/rust/frb_generated.dart';

abstract class Asr {
  // split when next word later than 1 second
  // ignore: non_constant_identifier_names
  static double THRESHOLD = 1.0;

  static Future<String> fromWAV(
    so.OnlineModelConfig? modelConfig,
    LLMSetting? zdppModel,
    Float32List data,
    int sampleRate,
  ) async {
    if (modelConfig == null) {
      return "";
    }

    // text 2 speech
    so.initBindings();
    final model = so.OnlineRecognizer(
      so.OnlineRecognizerConfig(model: modelConfig),
    );
    final stream = model.createStream();

    stream.acceptWaveform(samples: data, sampleRate: sampleRate);

    while (model.isReady(stream)) {
      model.decode(stream);
    }
    final res = model.getResult(stream);
    print(res);
    final raw = _splitByTime(res.tokens, res.timestamps);

    // if (zdppModel == null || raw.join().isEmpty) {
    return raw.join("\n");
    // } else {
    //   await RustLib.init();
    //   return llmEnhance(raw.join("\n"), zdppModel);
    // }
  }

  // static String llmEnhance(String input, LLMSetting s) {
  //   final processed = api.prompt(
  //     root: s.rootPath,
  //     system: s.prompt,
  //     prompt: input,
  //   );
  //   return _trim(processed, ["\n", "\t", " ", "<think>", "</think>"]);
  // }

  @DeepSeek()
  static List<String> _splitByTime(
    List<String> words,
    List<double> timestamps,
  ) {
    if (timestamps.isEmpty) {
      return [words.join()];
    }

    List<String> sentences = [];
    String currentSentence = "";
    double? lastTimestamp;

    for (int i = 0; i < words.length; i++) {
      if (lastTimestamp != null &&
          (timestamps[i] - lastTimestamp) > THRESHOLD) {
        sentences.add(currentSentence);
        currentSentence = words[i];
      } else {
        currentSentence += words[i];
      }
      lastTimestamp = timestamps[i];
    }

    // 处理最后一个句子
    if (currentSentence.isNotEmpty) {
      sentences.add(currentSentence);
    }

    return sentences;
  }

  // @DeepSeek()
  // static String _trim(String text, List<String> patterns) {
  //   if (text.isEmpty || patterns.isEmpty) {
  //     return text;
  //   }
  //
  //   // 去除开头的匹配模式
  //   int startIndex = 0;
  //   bool startFound = true;
  //
  //   while (startFound && startIndex < text.length) {
  //     startFound = false;
  //     for (String pattern in patterns) {
  //       if (pattern.isEmpty) continue;
  //
  //       if (text.startsWith(pattern, startIndex)) {
  //         startIndex += pattern.length;
  //         startFound = true;
  //         break; // 找到一个匹配就跳出循环，重新检查
  //       }
  //     }
  //   }
  //
  //   // 去除结尾的匹配模式
  //   int endIndex = text.length;
  //   bool endFound = true;
  //
  //   while (endFound && endIndex > startIndex) {
  //     endFound = false;
  //     for (String pattern in patterns) {
  //       if (pattern.isEmpty) continue;
  //
  //       if (text.substring(0, endIndex).endsWith(pattern)) {
  //         endIndex -= pattern.length;
  //         endFound = true;
  //         break; // 找到一个匹配就跳出循环，重新检查
  //       }
  //     }
  //   }
  //
  //   return text.substring(startIndex, endIndex);
  // }
}
