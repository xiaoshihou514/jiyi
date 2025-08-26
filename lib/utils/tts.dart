// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/src/rust/api/models/bpe.dart';
import 'package:jiyi/src/rust/api/tokenizer.dart' as tk;
import 'package:jiyi/src/rust/frb_generated.dart';

abstract class Tts {
  // 1 second
  static double THRESHOLD = 1.0;

  static Future<String> fromWAV(
    so.OnlineModelConfig? model,
    String? llmPath,
    String? tokenizerPath,
    Float32List data,
    int sampleRate,
  ) async {
    if (model == null) {
      return "";
    }

    // text 2 speech
    // so.initBindings();
    // final onnx = so.OnlineRecognizer(so.OnlineRecognizerConfig(model: model));
    // final stream = onnx.createStream();
    //
    // stream.acceptWaveform(samples: data, sampleRate: sampleRate);
    //
    // while (onnx.isReady(stream)) {
    //   onnx.decode(stream);
    // }
    // final res = onnx.getResult(stream);
    // final raw = _splitByTime(res.tokens, res.timestamps);
    final raw = ["收到请回复收到，完毕"];

    // LLM enhancement
    if (llmPath == null || tokenizerPath == null || raw.join().isEmpty) {
      return raw.join("\n");
    } else {
      return llmEnhance(raw, llmPath, tokenizerPath);
    }
  }

  static Future<String> llmEnhance(
    List<String> raw,
    String llmPath,
    String tokenizerPath,
  ) async {
    final ort = OnnxRuntime();
    final session = await ort.createSession(llmPath);

    await RustLib.init();
    final tmpDir = (await getTemporaryDirectory()).path;
    final dummy = path.join(tmpDir, tmpDir.hashCode.toString());
    File(dummy).createSync();
    final bpe = Bpe.fromFile(vocab: tokenizerPath, merges: dummy).build();

    print(raw);
    raw.forEach((s) {
      final t = bpe.tokenize(sequence: s);
      print("token: $t");
      print("id: ${t.map((t) => tk.id(t: t)).toList()}");
    });
    final ids = raw.map(
      (s) => bpe.tokenize(sequence: s).map((t) => tk.id(t: t)).toList(),
    );
    print(ids);
    final input = await OrtValue.fromList(
      ids.toList(),
      ids.map((xs) => xs.length).toList(),
    );

    print("run start");
    final outputs = await session.run({'input_ids': input});
    print(outputs);

    await input.dispose();
    await session.close();

    return raw.join("\n");
  }

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
