import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:flutter_recorder/flutter_recorder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:jiyi/utils/encryption.dart';
import 'package:jiyi/utils/secure_storage.dart' as ss;
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wav/wav_file.dart';
import 'package:wav/wav_format.dart';

import 'package:jiyi/components/soundviz.dart';
import 'package:jiyi/components/tape.dart';
import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/metadata.dart';
import 'package:jiyi/components/tapewheel.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/utils/stop_model.dart';
import 'package:jiyi/pages/default_colors.dart';

extension on num {
  double get em => (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
      ? sh / 100
      : sw / 96;
}

class RecordPage extends StatefulWidget {
  final String storagePath;
  const RecordPage(this.storagePath, {super.key});

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
  final GeolocatorPlatform _geo = GeolocatorPlatform.instance;

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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    bool isMobile = ScreenUtil().screenWidth < ScreenUtil().screenHeight;

    return Scaffold(
      backgroundColor: DefaultColors.bg,
      body: Padding(
        padding: EdgeInsets.all(8.em),
        child: Column(
          children: [
            Spacer(flex: isMobile ? 1 : 3),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SizedBox(width: 84.em, height: 50.em, child: Tape()),
                // tape "hole"
                Padding(
                  padding: EdgeInsets.only(bottom: 2.em),
                  child: Container(
                    width: isMobile ? 46.em : 50.em,
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
                  child: Text(
                    _startTime.toString(),
                    style: TextStyle(
                      fontSize: 4.em,
                      fontFamily: "851手写杂书体",
                      decoration: TextDecoration.none,
                      color: DefaultColors.info,
                    ),
                  ),
                ),
                // record time
                Positioned(
                  bottom: 2.5.em,
                  child: Text(
                    _printDuration(_duration),
                    style: TextStyle(
                      fontSize: 6.em,
                      fontFamily: "digital7-mono",
                      decoration: TextDecoration.none,
                      color: DefaultColors.bg,
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
                  onPressed: done ? () {} : _cancel,
                  icon: Icon(Icons.close, size: 20.em),
                ),
                IconButton(
                  onPressed: done ? () {} : _togglePause,
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
    _stop.value = true;

    // do this in another thread
    final coord = await _getLoc();
    await compute(encryptAndWrite, {
      'bytes': _bytes,
      'enc': Encryption.instance,
      'base_path': IO.STORAGE,
      'md': Metadata(
        time: _startTime,
        length: _duration,
        title: _startTime.toString(),
        latitude: coord.latitude,
        longitude: coord.longitude,
        cover: context.mounted
            ? (await showDialog<String>(
                    // ignore: use_build_context_synchronously
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => SingleCharInput(),
                  ) ??
                  "❔")
            : "❔",
        transcript: "TODO", // TODO: implement transcription using local STT
      ).dyn,
    });

    _cleanup();
    if (mounted) Navigator.pop(context);
  }

  static Future<void> encryptAndWrite(Map<String, dynamic> params) async {
    final bytes = params['bytes'] as List<double>;
    final md = Metadata.fromDyn(params['md'] as Map<String, dynamic>);
    Encryption.initByInstance(params['enc']);
    IO.STORAGE = params['base_path'];

    final data = Wav(
      [Float64List.fromList(bytes)],
      44100,
      WavFormat.pcm32bit,
    ).write();
    await IO.save(data, md);
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

  Future<LatLng> _getLoc() async {
    bool serviceEnabled = await _geo.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _geo.openLocationSettings();
    }
    LocationPermission permission = await _geo.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geo.requestPermission();
    }
    final pos = await _geo.getCurrentPosition();
    return LatLng(pos.altitude, pos.longitude);
  }

  void _micError(String msg) {
    if (!mounted) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DefaultColors.bg,
        icon: Icon(Icons.mic_off, color: DefaultColors.error),
        title: Text(
          AppLocalizations.of(context)!.mic_error_title,
          style: TextStyle(
            fontSize: 8.em,
            color: DefaultColors.keyword,
            fontFamily: "朱雀仿宋",
          ),
        ),
        content: Text(
          msg,
          style: TextStyle(
            fontSize: 6.em,
            color: DefaultColors.fg,
            fontFamily: "朱雀仿宋",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => {Navigator.pop(context)},
            child: Text(
              AppLocalizations.of(context)!.mic_error_ok,
              style: TextStyle(
                fontSize: 6.em,
                color: DefaultColors.constant,
                fontFamily: "朱雀仿宋",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SingleCharInput extends StatefulWidget {
  const SingleCharInput({super.key});

  @override
  State<SingleCharInput> createState() => _SingleCharInputState();
}

class _SingleCharInputState extends State<SingleCharInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(
      context,
      _controller.text.length == 1 ? _controller.text : "❔",
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: DefaultColors.shade_2,
      title: Text(
        l.cover_desc,
        style: TextStyle(
          decoration: TextDecoration.none,
          color: DefaultColors.info,
          fontFamily: "朱雀仿宋",
          fontSize: 4.em,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => _submit(),
          child: Text(
            l.download_exit,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: DefaultColors.constant,
              fontFamily: "朱雀仿宋",
              fontSize: 3.em,
            ),
          ),
        ),
      ],
      content: Padding(
        padding: EdgeInsets.all(1.em),
        child: Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: DefaultColors.shade_3,
              selectionHandleColor: DefaultColors.shade_4,
            ),
          ),
          child: TextField(
            controller: _controller,
            maxLength: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              decoration: TextDecoration.none,
              color: DefaultColors.fg,
              fontFamily: "朱雀仿宋",
              fontSize: 3.em,
            ),
            autofocus: true,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: DefaultColors.fg),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: DefaultColors.fg),
              ),
            ),
            cursorColor: DefaultColors.shade_6,
            onSubmitted: (_) => _submit(),
          ),
        ),
      ),
    );
  }
}
