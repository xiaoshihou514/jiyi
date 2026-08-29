import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:jiyi/components/soundviz.dart';
import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/l10n/localizations.dart';
import 'package:jiyi/services/encryption.dart';
import 'package:jiyi/services/io.dart';
import 'package:jiyi/utils/data/metadata.dart';
import 'package:jiyi/utils/em.dart';

/// Immersive playback view: the recording becomes a breathing orb of light,
/// ringed by particles driven by the live FFT, with a progress halo.
class CosmicPlayer extends StatefulWidget {
  final Metadata md;
  const CosmicPlayer(this.md, {super.key});

  @override
  State<CosmicPlayer> createState() => _CosmicPlayerState();
}

class _CosmicPlayerState extends State<CosmicPlayer> {
  final SoLoud _soloud = SoLoud.instance;
  late final SoLoudVizSource _vizSource;
  AudioSource? _audioSource;
  SoundHandle? _handle;
  Timer? _positionTimer;
  Timer? _vizTimer;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _paused = false;
  bool _isLoading = true;
  String? _error;
  bool _cancelled = false;
  late AppLocalizations _l;

  // Heavily smoothed visualization data for a calm, solemn motion.
  double _vol = 0;
  Float32List _fft = Float32List(0);

  @override
  void initState() {
    super.initState();
    _vizSource = SoLoudVizSource();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final audioData = await compute(_read, {
        'base_path': IO.STORAGE,
        'enc': Encryption.instance,
        'file': widget.md.path,
      });

      if (!_soloud.isInitialized) {
        await _soloud.init();
      }
      _soloud.setVisualizationEnabled(true);

      _audioSource = await _soloud.loadMem(widget.md.path, audioData);
      _duration = _soloud.getLength(_audioSource!);
      _handle = await _soloud.play(_audioSource!);

      _positionTimer = Timer.periodic(
        const Duration(milliseconds: 50),
        (_) => _pollPosition(),
      );
      // Repaint the orb ~30fps with smoothed data while playing.
      _vizTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
        if (!mounted || _cancelled || _paused) return;
        final v = _vizSource.getVolume();
        _vol = _vol * 0.9 + v * 0.1;
        final f = _vizSource.getFft();
        if (f.isNotEmpty) {
          if (_fft.length != f.length) {
            _fft = Float32List.fromList(f);
          } else {
            for (var i = 0; i < f.length; i++) {
              _fft[i] = _fft[i] * 0.88 + f[i] * 0.12;
            }
          }
        }
        setState(() {});
      });

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _l.player_load_error(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  static Future<Uint8List> _read(Map<String, dynamic> params) async {
    Encryption.initByInstance(params['enc']);
    IO.STORAGE = params['base_path'];
    return await IO.read(params['file'] as String);
  }

  void _pollPosition() {
    if (_cancelled || !mounted || _handle == null) return;
    try {
      final pos = _soloud.getPosition(_handle!);
      if (pos >= _duration && !_paused) {
        _handle = null;
        setState(() {
          _position = _duration;
          _paused = true;
        });
      } else {
        setState(() => _position = pos);
      }
    } catch (_) {}
  }

  Future<void> _toggle() async {
    if (_audioSource == null) return;
    if (_handle == null) {
      _handle = await _soloud.play(_audioSource!);
      _soloud.seek(_handle!, Duration.zero);
      setState(() {
        _position = Duration.zero;
        _paused = false;
      });
      return;
    }
    _paused = !_paused;
    _soloud.setPause(_handle!, _paused);
    setState(() {});
  }

  @override
  void dispose() {
    _cancelled = true;
    _positionTimer?.cancel();
    _vizTimer?.cancel();
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
    _l = AppLocalizations.of(context)!;
    final dateStr = DateFormat('yyyy-MM-dd  HH:mm').format(widget.md.time);

    return Scaffold(
      backgroundColor: Color(0xFF07090D),
      body: SafeArea(
        child: Column(
          children: [
            // top bar
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 8.em,
                  ),
                ),
                Spacer(),
                Text(
                  widget.md.title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontFamily: "851手写杂书体",
                    fontSize: 6.em,
                    decoration: TextDecoration.none,
                  ),
                ),
                Spacer(),
                SizedBox(width: 14.em),
              ],
            ),

            // orb
            Expanded(
              flex: 5,
              child: _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Color(0xFFD89E98),
                          fontSize: 5.em,
                        ),
                      ),
                    )
                  : _isLoading
                  ? Center(
                      child: Spinner(
                        Icons.sync,
                        Color(0xFF8FB8D8),
                        30.em,
                      ),
                    )
                  : GestureDetector(
                      onTap: _toggle,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _OrbPainter(
                          volume: _paused ? 0 : _vol,
                          fft: _paused ? Float32List(0) : _fft,
                          progress: _duration.inMilliseconds == 0
                              ? 0
                              : _position.inMilliseconds /
                                    _duration.inMilliseconds,
                          paused: _paused,
                          hue: _hueForHour(widget.md.time.hour),
                        ),
                      ),
                    ),
            ),

            if (!_isLoading && _error == null) ...[
              Text(
                '${_fmt(_position)}  /  ${_fmt(_duration)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontFamily: "digital7-mono",
                  fontSize: 6.em,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 1.em),
              Text(
                dateStr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 4.em,
                  fontFamily: "朱雀仿宋",
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: 2.em),
              if (widget.md.transcript.isNotEmpty)
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.em),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.md.transcript,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 4.5.em,
                          fontFamily: "朱雀仿宋",
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Spacer(flex: 2),
            ] else
              Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  static Color _hueForHour(int hour) {
    if (hour < 5 || hour >= 20) return Color(0xFF8FB8D8);
    if (hour < 9) return Color(0xFFE8C982);
    if (hour < 17) return Color(0xFFD8DEE6);
    return Color(0xFFC59EB4);
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, "0");
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }
}

class _OrbPainter extends CustomPainter {
  final double volume; // 0..1
  final Float32List fft;
  final double progress; // 0..1
  final bool paused;
  final Color hue;

  _OrbPainter({
    required this.volume,
    required this.fft,
    required this.progress,
    required this.paused,
    required this.hue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final base = min(size.width, size.height) * 0.22;
    final vol = volume.clamp(0.0, 1.0);
    final r = base * (1 + vol * 0.18);

    // outer glow
    canvas.drawCircle(
      c,
      r * 1.9,
      Paint()
        ..color = hue.withValues(alpha: 0.05 + vol * 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 40 + vol * 30),
    );

    // core
    final coreRect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Color.lerp(hue, Colors.white, 0.8)!.withValues(alpha: 0.95),
            hue.withValues(alpha: 0.75),
            hue.withValues(alpha: 0.10),
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(coreRect),
    );

    // particle ring driven by FFT bands
    if (fft.isNotEmpty) {
      const count = 64;
      for (var i = 0; i < count; i++) {
        final angle = i / count * 2 * pi - pi / 2;
        final band = fft[(i * fft.length ~/ count).clamp(0, fft.length - 1)]
            .abs()
            .clamp(0.0, 1.0);
        final pr = r * 1.25 + band * base * 0.45;
        final p = Offset(
          c.dx + pr * cos(angle),
          c.dy + pr * sin(angle),
        );
        canvas.drawCircle(
          p,
          1.2 + band * 1.5,
          Paint()..color = hue.withValues(alpha: 0.25 + band * 0.4),
        );
      }
    }

    // progress halo
    final haloRect = Rect.fromCircle(center: c, radius: r * 1.6);
    canvas.drawArc(
      haloRect,
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.10),
    );
    canvas.drawArc(
      haloRect,
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = hue.withValues(alpha: 0.9),
    );

    // paused icon hint
    if (paused) {
      final icon = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(Icons.play_arrow.codePoint),
          style: TextStyle(
            fontFamily: Icons.play_arrow.fontFamily,
            package: Icons.play_arrow.fontPackage,
            fontSize: r * 0.9,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      icon.paint(canvas, Offset(c.dx - icon.width / 2, c.dy - icon.height / 2));
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => true;
}
