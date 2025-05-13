import 'dart:io';

import 'package:audio_visualizer/audio_visualizer.dart';
import 'package:audio_visualizer/visualizers/bar_visualizer.dart';
import 'package:audio_visualizer/visualizers/circular_bar_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/em.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with WidgetsBindingObserver {
  bool _isPaused = false;
  final source = PCMVisualizer();

  @override
  void dispose() {
    super.dispose();
    source.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    _recorderInit();

    return Scaffold(
      backgroundColor: DefaultColors.bg,
      body: Padding(
        padding: EdgeInsets.all(8.em),
        child: Column(
          children: [
            SizedBox(
              height: 50.em,
              width: 50.em,
              child: ListenableBuilder(
                listenable: source,
                builder: (context, child) {
                  return CircularBarVisualizer(
                    input: source.value.waveform,
                    backgroundColor: DefaultColors.bg,
                    color: DefaultColors.special,
                    gap: 2,
                  );
                },
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _togglePause,
                  icon: Icon(
                    _isPaused ? Icons.play_arrow : Icons.pause,
                    size: 20.em,
                  ),
                ),
                IconButton(
                  onPressed: _cancel,
                  icon: Icon(Icons.cancel, size: 20.em),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
    if (_isPaused) {
      Recorder.instance.stopStreamingData();
    } else {
      Recorder.instance.startStreamingData();
    }
  }

  void _cancel() {
    // TODO
  }

  Future<void> _ensurePermission() async {
    if (!await Permission.microphone.status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _recorderInit() async {
    print("_recorderInit");
    if (Platform.isAndroid) {
      _ensurePermission();
    }
    try {
      await Recorder.instance.init(format: PCMFormat.s16le);
      Recorder.instance.start();
    } on Exception catch (e) {
      _micError(e.toString());
    }
    Recorder.instance.uint8ListStream.listen((data) {
      source.feed(data.toU8List(from: PCMFormat.s16le));
    });
    Recorder.instance.startStreamingData();
  }

  void _micError(String msg) {
    if (!mounted) {
      return;
    }
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: DefaultColors.bg,
            icon: Icon(Icons.mic_off, color: DefaultColors.error),
            title: Text.rich(
              TextSpan(
                text: AppLocalizations.of(context)!.mic_error_title,
                style: TextStyle(
                  fontSize: 8.em,
                  color: DefaultColors.keyword,
                  fontFamily: "朱雀仿宋",
                ),
              ),
            ),
            content: Text.rich(
              TextSpan(
                text: msg,
                style: TextStyle(
                  fontSize: 6.em,
                  color: DefaultColors.fg,
                  fontFamily: "朱雀仿宋",
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => {Navigator.pop(context)},
                child: Text.rich(
                  TextSpan(
                    text: AppLocalizations.of(context)!.mic_error_ok,
                    style: TextStyle(
                      fontSize: 6.em,
                      color: DefaultColors.constant,
                      fontFamily: "朱雀仿宋",
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
