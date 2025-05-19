import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_recorder/flutter_recorder.dart';

import 'package:jiyi/pages/default_colors.dart';

class SoundViz extends StatefulWidget {
  const SoundViz({super.key});

  @override
  State<SoundViz> createState() => SoundVizState();
}

class SoundVizState extends State<SoundViz>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker(_tick);
    ticker.start();
  }

  @override
  void dispose() {
    ticker.stop();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    if (context.mounted && Recorder.instance.isDeviceStarted()) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        key: UniqueKey(),
        painter: SoundVizPainter(),
        child: Container(),
      ),
    );
  }
}

class SoundVizPainter extends CustomPainter {
  SoundVizPainter();
  static final offsets = DoubleLinkedQueue();
  static final stroke = Paint();
  static const sampleSize = 256;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    if (!Recorder.instance.isDeviceStarted()) return;
    final data = Recorder.instance.getFft(alwaysReturnData: true);
    if (data.isEmpty) return;
    final db = (Recorder.instance.getVolumeDb() + 100) / 100;

    offsets.addFirst((
      data
              .slices(8)
              .map((xs) => xs.sum)
              .mapIndexed((i, freq) => i * freq)
              .reduce((x, y) => x + y) /
          List.generate(32, (i) => i, growable: false).sum /
          4,
      db,
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
        ..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(SoundVizPainter oldDelegate) {
    return true;
  }
}
