import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:intl/intl.dart';
import 'package:jiyi/components/soundviz.dart';
import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/components/tape.dart';
import 'package:jiyi/components/tapewheel.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/services/geo.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/services/encryption.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/services/io.dart';
import 'package:jiyi/utils/stop_model.dart';

@DeepSeek()
class Player extends StatefulWidget {
  final Metadata _md;
  const Player(this._md, {super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final StopModel _stop = StopModel();
  final SoLoud _soloud = SoLoud.instance;
  late final SoLoudVizSource _vizSource;
  AudioSource? _audioSource;
  SoundHandle? _handle;
  Timer? _positionTimer;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isLoading = true;
  String? _error;
  bool _cancelled = false;
  String? _resolvedGeoDesc;

  @override
  void initState() {
    super.initState();
    _vizSource = SoLoudVizSource();
    _initPlayer();
    _initGeoDesc();
  }

  Future<void> _initPlayer() async {
    try {
      final audioData = await compute(_read, {
        'base_path': IO.STORAGE,
        'enc': Encryption.instance,
        'file': widget._md.path,
      });

      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      _soloud.setVisualizationEnabled(true);

      _audioSource = await _soloud.loadMem(widget._md.path, audioData);
      _duration = _soloud.getLength(_audioSource!);
      _handle = await _soloud.play(_audioSource!);

      _positionTimer = Timer.periodic(
        const Duration(milliseconds: 50),
        (_) => _pollPosition(),
      );

      if (!_cancelled && mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载失败: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _pollPosition() {
    if (_cancelled || !mounted || _handle == null) return;
    try {
      final pos = _soloud.getPosition(_handle!);
      // Detect natural end-of-playback.
      if (pos >= _duration && !_stop.value) {
        setState(() {
          _position = _duration;
          _stop.set(true);
        });
      } else {
        setState(() => _position = pos);
      }
    } catch (_) {}
  }

  Future<void> _initGeoDesc() async {
    if (widget._md.geodesc != null) {
      setState(() => _resolvedGeoDesc = widget._md.geodesc);
      return;
    }
    if (widget._md.hasGeo) {
      try {
        final desc = await Geo().getLocationDescription(
          widget._md.latitude!,
          widget._md.longitude!,
        );
        if (!_cancelled && mounted) {
          setState(
            () => _resolvedGeoDesc =
                desc ??
                '${widget._md.latitude!.toStringAsFixed(4)}, '
                    '${widget._md.longitude!.toStringAsFixed(4)}',
          );
        }
      } catch (_) {
        if (!_cancelled && mounted) {
          setState(
            () => _resolvedGeoDesc =
                '${widget._md.latitude!.toStringAsFixed(4)}, '
                '${widget._md.longitude!.toStringAsFixed(4)}',
          );
        }
      }
    }
  }

  static Future<Uint8List> _read(Map<String, dynamic> params) async {
    Encryption.initByInstance(params['enc']);
    IO.STORAGE = params['base_path'];
    return await IO.read(params['file'] as String);
  }

  @override
  void dispose() {
    _cancelled = true;
    _positionTimer?.cancel();
    _vizSource.dispose();
    if (_handle != null && _audioSource != null) {
      try {
        _soloud.stop(_handle!);
        _soloud.disposeSource(_audioSource!);
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    bool isMobile = ScreenUtil().screenWidth < ScreenUtil().screenHeight;

    return Scaffold(
      backgroundColor: DefaultColors.bg,
      appBar: AppBar(
        backgroundColor: DefaultColors.bg,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Padding(
            padding: EdgeInsets.all(2.em),
            child: Icon(Icons.arrow_back, color: DefaultColors.fg, size: 8.em),
          ),
        ),
        actions: [
          if (!_isLoading && _error == null)
            IconButton(
              onPressed: _exportWav,
              icon: Icon(Icons.share, color: DefaultColors.fg, size: 8.em),
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.em),
        child: Column(
          children: [
            Spacer(flex: isMobile ? 1 : 3),

            if (_error != null)
              Padding(
                padding: EdgeInsets.all(8.em),
                child: Text(
                  _error!,
                  style: TextStyle(color: DefaultColors.error, fontSize: 6.em),
                ),
              )
            else if (_isLoading)
              Center(child: Spinner(Icons.sync, DefaultColors.keyword, 30.em))
            else if (isMobile)
              _cdViz(isMobile)
            else // desktop
              SizedBox(
                height: 50.em,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _cdViz(isMobile),
                    SizedBox(width: 11.em),
                    _transcript,
                  ],
                ),
              ),

            if (!_isLoading && _error == null) ...[
              SizedBox(height: 3.em),
              _metaStrip,
            ],

            Spacer(flex: 1),

            // 字幕
            if (!_isLoading && _error == null && isMobile) _transcript,

            Spacer(flex: 1),

            // 进度条
            if (!_isLoading && _error == null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.em),
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 1.5.em,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 4.em,
                      disabledThumbRadius: 4.em,
                    ),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 8.em),
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inSeconds.toDouble(),
                    value: min(
                      _position.inSeconds.toDouble(),
                      _duration.inSeconds.toDouble(),
                    ),
                    onChanged: (value) {
                      if (_handle != null) {
                        _soloud.seek(
                          _handle!,
                          Duration(seconds: value.toInt()),
                        );
                      }
                    },
                    activeColor: DefaultColors.func,
                    inactiveColor: DefaultColors.shade_4,
                  ),
                ),
              ),

            // 控制按钮
            if (!_isLoading && _error == null)
              Center(
                child: IconButton(
                  onPressed: _togglePause,
                  icon: Icon(
                    _stop.value ? Icons.play_arrow : Icons.pause,
                    size: 20.em,
                    color: DefaultColors.fg,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget get _transcript {
    final l = AppLocalizations.of(context)!;
    final content = widget._md.transcript;
    return Expanded(
      child: SingleChildScrollView(
        child: Wrap(
          children: [
            Container(
              color: DefaultColors.shade_1,
              child: Text(
                content.isEmpty ? l.transcript_empty : content,
                style: TextStyle(
                  color: DefaultColors.fg,
                  fontFamily: "朱雀仿宋",
                  fontSize: 4.em,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _metaStrip {
    final md = widget._md;
    final dateStr = DateFormat('yyyy-MM-dd  HH:mm').format(md.time);
    final durStr = _printDuration(md.length);

    Widget chip(IconData icon, String label) => Container(
      padding: EdgeInsets.symmetric(horizontal: 3.em, vertical: 1.em),
      decoration: BoxDecoration(
        color: DefaultColors.shade_1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 4.em, color: DefaultColors.info),
          SizedBox(width: 1.5.em),
          Text(
            label,
            style: TextStyle(
              fontSize: 4.em,
              color: DefaultColors.fg,
              fontFamily: "朱雀仿宋",
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );

    return Wrap(
      spacing: 3.em,
      runSpacing: 2.em,
      alignment: WrapAlignment.center,
      children: [
        chip(Icons.calendar_today, dateStr),
        chip(Icons.timer_outlined, durStr),
        if (_resolvedGeoDesc != null)
          chip(Icons.location_on_outlined, _resolvedGeoDesc!),
      ],
    );
  }

  Stack _cdViz(bool isMobile) {
    return Stack(
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
              border: Border.all(color: DefaultColors.shade_3, width: 1.em),
            ),
          ),
        ),
        // sound wave
        Padding(
          padding: EdgeInsets.only(bottom: 2.em),
          child: SizedBox(
            width: 32.em,
            height: 12.em,
            child: SoundViz(_stop, source: _vizSource),
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
              border: Border.all(color: DefaultColors.func, width: 0.8.em),
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
              border: Border.all(color: DefaultColors.func, width: 0.8.em),
            ),
            child: FittedBox(child: Tapewheel(_stop)),
          ),
        ),
        // tape title
        Positioned(
          top: 8.em,
          child: Text(
            widget._md.title,
            style: TextStyle(
              fontSize: 4.em,
              fontFamily: "851手写杂书体",
              decoration: TextDecoration.none,
              color: DefaultColors.fg,
            ),
          ),
        ),
        // record time
        Positioned(
          bottom: 2.5.em,
          child: Text(
            _printDuration(_position),
            style: TextStyle(
              fontSize: 6.em,
              fontFamily: "digital7-mono",
              decoration: TextDecoration.none,
              color: DefaultColors.fg,
            ),
          ),
        ),
      ],
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _exportWav() async {
    final bytes = await compute(_read, {
      'base_path': IO.STORAGE,
      'enc': Encryption.instance,
      'file': widget._md.path,
    });

    final fileName = '${widget._md.title}.wav';

    if (Platform.isAndroid || Platform.isIOS) {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export WAV',
        fileName: fileName,
        bytes: bytes,
      );
      if (savePath == null) return;
    } else {
      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Export WAV',
        fileName: fileName,
      );
      if (savePath == null) return;
      await File(savePath).writeAsBytes(bytes);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported $fileName'),
          backgroundColor: DefaultColors.shade_3,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _togglePause() {
    if (_handle == null) return;
    _stop.flip();
    _soloud.setPause(_handle!, _stop.value);
  }
}
