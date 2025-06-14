// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:jiyi/utils/anno.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

abstract class Tts {
  // 1 second
  static double THRESHOLD = 1.0;

  static String fromWAV(
    so.OnlineModelConfig? model,
    Float32List data,
    int sampleRate,
  ) {
    if (model == null) {
      return "";
    }
    so.initBindings();
    final onnx = so.OnlineRecognizer(so.OnlineRecognizerConfig(model: model));
    final stream = onnx.createStream();

    stream.acceptWaveform(samples: data, sampleRate: sampleRate);

    while (onnx.isReady(stream)) {
      onnx.decode(stream);
    }
    final res = onnx.getResult(stream);
    final words = res.tokens;
    final timestamps = res.timestamps;

    @DeepSeek()
    List<String> sentences = [];
    String currentSentence = "";
    double? lastTimestamp;

    for (int i = 0; i < words.length; i++) {
      if (lastTimestamp != null &&
          (timestamps[i] - lastTimestamp) > THRESHOLD) {
        // 时间间隔超过阈值，开始新句子
        sentences.add(currentSentence);
        currentSentence = words[i];
      } else {
        // 时间间隔在阈值内，继续当前句子
        if (currentSentence.isNotEmpty) {
          currentSentence += words[i];
        } else {
          currentSentence = words[i];
        }
      }
      lastTimestamp = timestamps[i];
    }

    // 添加最后一个句子
    if (currentSentence.isNotEmpty) {
      sentences.add(currentSentence);
    }

    // 输出结果
    return sentences.join("\n");
  }
}
