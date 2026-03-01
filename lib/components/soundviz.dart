import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/stop_model.dart';

/// Abstract data source for the sound visualization.
abstract class VizSource {
  bool get isActive;
  Float32List getFft();
  double getVolume(); // 0.0 – 1.0
  void dispose();
}

/// Uses the microphone recorder (during recording).
class RecorderVizSource implements VizSource {
  static final _r = Recorder.instance;

  @override
  bool get isActive => _r.isDeviceStarted();

  @override
  Float32List getFft() => _r.getFft(alwaysReturnData: true);

  @override
  double getVolume() => (_r.getVolumeDb() + 100) / 100;

  @override
  void dispose() {} // recorder lifecycle managed by the recording page
}

/// Uses flutter_soloud's AudioData for playback visualization.
class SoLoudVizSource implements VizSource {
  final AudioData _audioData = AudioData(GetSamplesKind.linear);

  @override
  bool get isActive => SoLoud.instance.isInitialized;

  @override
  Float32List getFft() {
    try {
      _audioData.updateSamples();
      final data = _audioData.getAudioData();
      if (data.length < 256) return Float32List(0);
      return Float32List.sublistView(data, 0, 256);
    } catch (_) {
      return Float32List(0);
    }
  }

  @override
  double getVolume() {
    try {
      final data = _audioData.getAudioData();
      if (data.length < 512) return 0;
      double max = 0;
      for (var i = 256; i < 512; i++) {
        final v = data[i].abs();
        if (v > max) max = v;
      }
      return max.clamp(0.0, 1.0);
    } catch (_) {
      return 0;
    }
  }

  @override
  void dispose() => _audioData.dispose();
}

class SoundViz extends StatefulWidget {
  final StopModel _stop;
  final VizSource _source;

  /// [source] defaults to [RecorderVizSource] (microphone) if not provided.
  const SoundViz(this._stop, {super.key, VizSource? source})
      : _source = source ?? const _DefaultSource();

  @override
  State<SoundViz> createState() => SoundVizState();
}

// Sentinel so we can write a const default — delegates to RecorderVizSource.
class _DefaultSource implements VizSource {
  const _DefaultSource();
  static final _inner = RecorderVizSource();
  @override
  bool get isActive => _inner.isActive;
  @override
  Float32List getFft() => _inner.getFft();
  @override
  double getVolume() => _inner.getVolume();
  @override
  void dispose() {}
}

class SoundVizState extends State<SoundViz> {
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 16), (Timer t) => _tick());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _tick() {
    if (context.mounted && !widget._stop.value && widget._source.isActive) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        key: UniqueKey(),
        painter: SoundVizPainter(widget._stop, widget._source),
        child: Container(),
      ),
    );
  }
}

class SoundVizPainter extends CustomPainter {
  static final stroke = Paint();
  static const sampleSize = 256;

  final StopModel _stop;
  final VizSource _source;
  static final offsets = DoubleLinkedQueue<(double, double)>();

  SoundVizPainter(this._stop, this._source);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    if (!_source.isActive) return;
    final data = _source.getFft();
    if (data.isEmpty) return;
    final vol = _source.getVolume();

    offsets.addFirst((
      (data
                  .slices(8)
                  .map((xs) => xs.sum)
                  .mapIndexed((i, freq) => i * freq)
                  .reduce((x, y) => x + y) /
              List.generate(32, (i) => i, growable: false).sum)
          .clamp(0.0, 1.0),
      vol,
    ));
    if (offsets.length > sampleSize) {
      offsets.removeLast();
    }

    offsets.forEachIndexed((i, data) {
      var rect = Rect.fromLTWH(
        (sampleSize - (i + 1)) / sampleSize * size.width,
        (0.5 - data.$1 / 2) * size.height,
        size.width / sampleSize,
        data.$1 * size.height,
      );
      canvas.drawRect(
        rect,
        stroke
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DefaultColors.keyword,
              Color.lerp(DefaultColors.keyword, DefaultColors.error, data.$2)!,
              DefaultColors.error,
            ],
          ).createShader(rect),
      );
    });
    canvas.drawLine(
      Offset(0.0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = DefaultColors.shade_3
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(SoundVizPainter oldDelegate) => !_stop.value;
}

