import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/utils/encryption.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

import 'package:jiyi/components/soundviz.dart';
import 'package:jiyi/components/tape.dart';
import 'package:jiyi/components/tapewheel.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/utils/stop_model.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:wav/wav_file.dart';
import 'package:wav/wav_format.dart';

extension on num {
  double get em =>
      (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
          ? sh / 100
          : sw / 96;
}

class RecordPage extends StatefulWidget {
  final String storagePath;
  final Encryption encryption;
  const RecordPage(this.encryption, this.storagePath, {super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final StopModel _stop = StopModel();
  final Recorder _recorder = Recorder.instance;
  late final Timer timer;

  // timer state
  final _startTime = DateTime.now().toLocal();
  Duration _duration = Duration.zero;
  late DateTime _pausedAt;
  Duration _pausedTime = Duration.zero;

  // io stuff
  final List<double> _bytes = List.empty(growable: true);
  bool _cancelled = false;

  // done animation
  bool done = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(milliseconds: 16), (Timer t) => _tick());
    _recorderInit();
  }

  void _tick() {
    if (context.mounted && !_stop.value) {
      setState(() {
        _duration = DateTime.now().difference(_startTime) - _pausedTime;
      });
    }
  }

  bool get _isMobile => ScreenUtil().screenWidth < ScreenUtil().screenHeight;

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: DefaultColors.bg,
      body: Padding(
        padding: EdgeInsets.all(8.em),
        child: Column(
          children: [
            Spacer(flex: _isMobile ? 1 : 3),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SizedBox(width: 84.em, height: 50.em, child: Tape()),
                // tape "hole"
                Padding(
                  padding: EdgeInsets.only(bottom: 2.em),
                  child: Container(
                    width: _isMobile ? 46.em : 50.em,
                    height: 18.05.em,
                    decoration: BoxDecoration(
                      color: DefaultColors.bg,
                      borderRadius: BorderRadius.circular(8.5.em),
                      border: Border.all(
                        color: DefaultColors.shade_3,
                        width: 1.em,
                      ),
                    ),
                  ),
                ),
                // sound wave
                Padding(
                  padding: EdgeInsets.only(bottom: 2.em),
                  child: SizedBox(
                    width: 32.em,
                    height: 12.em,
                    child: SoundViz(_stop),
                  ),
                ),
                // tape cog - left
                Positioned(
                  top: 16.em,
                  left: 18.em,
                  child: Container(
                    width: 16.em,
                    height: 16.em,
                    decoration: BoxDecoration(
                      color: DefaultColors.shade_6,
                      borderRadius: BorderRadius.circular(8.em),
                      border: Border.all(
                        color: DefaultColors.func,
                        width: 0.8.em,
                      ),
                    ),
                    child: FittedBox(child: Tapewheel(_stop)),
                  ),
                ),
                // tape cog - right
                Positioned(
                  top: 16.em,
                  right: 18.em,
                  child: Container(
                    width: 16.em,
                    height: 16.em,
                    decoration: BoxDecoration(
                      color: DefaultColors.shade_6,
                      borderRadius: BorderRadius.circular(8.em),
                      border: Border.all(
                        color: DefaultColors.func,
                        width: 0.8.em,
                      ),
                    ),
                    child: FittedBox(child: Tapewheel(_stop)),
                  ),
                ),
                // tape title
                Positioned(
                  top: 8.em,
                  child: Text.rich(
                    TextSpan(
                      text: _startTime.toString(),
                      style: TextStyle(
                        fontSize: 4.em,
                        fontFamily: "851手写杂书体",
                        decoration: TextDecoration.none,
                        color: DefaultColors.info,
                      ),
                    ),
                  ),
                ),
                // record time
                Positioned(
                  bottom: 2.5.em,
                  child: Text.rich(
                    TextSpan(
                      text: _printDuration(_duration),
                      style: TextStyle(
                        fontSize: 6.em,
                        fontFamily: "digital7-mono",
                        decoration: TextDecoration.none,
                        color: DefaultColors.bg,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(flex: 1),
            // control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _cancel,
                  icon: Icon(Icons.close, size: 20.em),
                ),
                IconButton(
                  onPressed: _togglePause,
                  icon: Icon(
                    _stop.value ? Icons.play_arrow : Icons.pause,
                    size: 20.em,
                  ),
                ),
                done
                    ? Spinner(Icons.sync, DefaultColors.keyword, 20.em)
                    : IconButton(
                      onPressed: _done,
                      icon: Icon(Icons.stop, size: 20.em),
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _togglePause() {
    _stop.flip();
    _recorder.setPauseRecording(pause: _stop.value);
    if (_stop.value) {
      _recorder.stopStreamingData();
    } else {
      _recorder.startStreamingData();
    }

    setState(() {
      if (_stop.value) {
        _pausedAt = DateTime.now().toLocal();
      } else {
        _pausedTime += DateTime.now().toLocal().difference(_pausedAt);
      }
    });
  }

  void _cancel() {
    _cleanup();
    Navigator.pop(context);
  }

  Future<void> _done() async {
    setState(() => done = true);

    // do this in another thread
    final params = {
      'bytes': _bytes,
      'storagePath': widget.storagePath,
      'startTime': "${_startTime.toString()}.cd",
      'encryption': widget.encryption,
    };
    await compute(encryptAndWrite, params);

    _cleanup();
    if (mounted) Navigator.pop(context);
  }

  static Future<void> encryptAndWrite(Map<String, dynamic> params) async {
    final bytes = params['bytes'] as List<double>;
    final storagePath = params['storagePath'] as String;
    final fileName = params['startTime'] as String;
    final encryption = params['encryption'] as Encryption;

    final wav = Wav([Float64List.fromList(bytes)], 44100, WavFormat.pcm32bit);
    final wavData = wav.write();

    final encrypted = await encryption.encrypt(wavData);

    final file = File(path.join(storagePath, fileName));
    await file.writeAsBytes(encrypted.toList(growable: false));
  }

  void _cleanup() {
    _recorder.stopStreamingData();
    _recorder.deinit();
    timer.cancel();
    _cancelled = true;
  }

  Future<void> _ensurePermission() async {
    if (!await Permission.microphone.status.isGranted) {
      await Permission.microphone.request();
    }
  }

  Future<void> _recorderInit() async {
    if (Platform.isAndroid) {
      _ensurePermission();
    }
    try {
      await _recorder.init(
        channels: RecorderChannels.stereo,
        format: PCMFormat.f32le,
      );
      _recorder.start();
    } on Exception catch (e) {
      _micError(e.toString());
    }
    _recorder.uint8ListStream.listen((data) {
      if (!_cancelled) {
        _bytes.addAll(data.toF32List(from: PCMFormat.f32le));
      }
    });
    _recorder.startStreamingData();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
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
