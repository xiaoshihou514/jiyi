// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:jiyi/utils/anno.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

abstract class Tts {
  // 1 second
  static double THRESHOLD = 1.0;

  // 防结巴处理函数
  static String _compressRepeatingChars(String input) {
    if (input.isEmpty) return input;

    StringBuffer result = StringBuffer();
    List<String> chars = input.split('');
    int i = 0;

    while (i < chars.length) {
      String currentChar = chars[i];
      int repeatCount = 1;

      // 检查是否是中文字符（Unicode范围）
      bool isChinese = currentChar.runes.any(
        (rune) => rune >= 0x4E00 && rune <= 0x9FFF,
      );

      // 如果是中文字符，计算连续重复次数
      if (isChinese) {
        int j = i + 1;
        while (j < chars.length && chars[j] == currentChar) {
          repeatCount++;
          j++;
        }

        // 如果连续重复3次或以上，只保留一个
        if (repeatCount >= 3) {
          result.write(currentChar);
          i = j; // 跳过重复字符
          continue;
        }
      }

      // 非重复字符或重复次数不足3次
      for (int k = 0; k < repeatCount; k++) {
        result.write(currentChar);
      }
      i += repeatCount;
    }

    return result.toString();
  }

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
        // 添加防结巴处理
        currentSentence = _compressRepeatingChars(currentSentence);
        sentences.add(currentSentence);
        currentSentence = words[i];
      } else {
        currentSentence += words[i];
      }
      lastTimestamp = timestamps[i];
    }

    // 处理最后一个句子
    if (currentSentence.isNotEmpty) {
      currentSentence = _compressRepeatingChars(currentSentence);
      sentences.add(currentSentence);
    }

    return sentences.join("\n");
  }
}
