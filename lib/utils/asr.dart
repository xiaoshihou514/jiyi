import 'dart:typed_data';
import 'package:sherpa_onnx/sherpa_onnx.dart' as so;

abstract class Asr {
  // split when next word later than 1 second
  // ignore: non_constant_identifier_names
  static double THRESHOLD = 1.0;

  static Future<String> fromWAV(
    so.OnlineModelConfig? modelConfig,
    so.OfflinePunctuationConfig? zdppConfig,
    Float32List data,
    int sampleRate,
  ) async {
    if (modelConfig == null) {
      return "";
    }

    // text 2 speech
    so.initBindings();
    final asrModel = so.OnlineRecognizer(
      so.OnlineRecognizerConfig(model: modelConfig),
    );
    final stream = asrModel.createStream();

    stream.acceptWaveform(samples: data, sampleRate: sampleRate);

    while (asrModel.isReady(stream)) {
      asrModel.decode(stream);
    }
    final res = asrModel.getResult(stream);
    final raw = res.text;

    if (zdppConfig == null || raw.isEmpty) {
      return raw;
    } else {
      return zdpp(raw, zdppConfig);
    }
  }

  static zdpp(String input, so.OfflinePunctuationConfig zdppConfig) {
    final zdppModel = so.OfflinePunctuation(config: zdppConfig);
    final result = zdppModel.addPunct(input);
    zdppModel.free();
    return result;
  }
}
