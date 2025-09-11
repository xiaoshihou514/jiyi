import 'dart:typed_data';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/src/rust/api.dart' as api;

abstract class Tts {
  // 1 second
  static double THRESHOLD = 1.0;

  static Future<String> fromWAV(
    so.OnlineModelConfig? model,
    String? llmPath,
    Float32List data,
    int sampleRate,
  ) async {
    if (model == null) {
      return "";
    }

    // text 2 speech
    so.initBindings();
    final onnx = so.OnlineRecognizer(so.OnlineRecognizerConfig(model: model));
    final stream = onnx.createStream();

    stream.acceptWaveform(samples: data, sampleRate: sampleRate);

    while (onnx.isReady(stream)) {
      onnx.decode(stream);
    }
    final res = onnx.getResult(stream);
    final raw = _splitByTime(res.tokens, res.timestamps);

    // LLM enhancement
    if (llmPath == null || raw.join().isEmpty) {
      return raw.join("\n");
    } else {
      return llmEnhance(raw.join("\n"), llmPath, llmPath);
    }
  }

  static String llmEnhance(String raw, String llmPath, String tokenizerPath) =>
      api.prompt(root: llmPath, system: "", prompt: raw);

  @DeepSeek()
  static List<String> _splitByTime(
    List<String> words,
    List<double> timestamps,
  ) {
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
}
