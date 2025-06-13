import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jiyi/components/soundviz.dart';
import 'package:jiyi/components/spinner.dart';
import 'package:jiyi/components/tape.dart';
import 'package:jiyi/components/tapewheel.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/anno.dart';
import 'package:jiyi/utils/em.dart';
import 'package:jiyi/utils/metadata.dart';
import 'package:jiyi/utils/io.dart';
import 'package:jiyi/utils/stop_model.dart';
import 'package:path_provider/path_provider.dart';

@DeepSeek()
class Player extends StatefulWidget {
  final Metadata _md;
  const Player(this._md, {super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final StopModel _stop = StopModel();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();

    // 设置位置监听器
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });

    // 设置时长监听器
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    // 设置播放状态监听器
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        _stop.value = !_isPlaying; // 同步暂停状态到磁带动画
      });
    });
  }

  Future<void> _initPlayer() async {
    try {
      // 读取音频文件
      final audioData = await IO.read(widget._md.path);

      // 创建临时文件播放
      final tempFile = await _createTempFile(audioData);

      // 设置音频源并准备播放
      await _audioPlayer.setSourceDeviceFile(tempFile.path);

      setState(() {
        _isLoading = false;
        _duration = widget._md.length;
      });
    } catch (e) {
      setState(() {
        _error = '加载失败: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<File> _createTempFile(Uint8List data) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_audio.mp3');
    await tempFile.writeAsBytes(data);
    return tempFile;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
            else
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
                      widget._md.title,
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
                      _printDuration(_position),
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
                    value: _position.inSeconds.toDouble(),
                    onChanged: (value) async {
                      await _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                    activeColor: DefaultColors.func,
                    inactiveColor: DefaultColors.shade_4,
                  ),
                ),
              ),

            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _togglePause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 20.em,
                    color: DefaultColors.fg,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _togglePause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }
}
