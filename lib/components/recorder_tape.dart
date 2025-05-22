import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jiyi/components/soundviz.dart';
import 'package:jiyi/components/tape.dart';
import 'package:jiyi/components/tapewheel.dart';
import 'package:jiyi/pages/default_colors.dart';

extension on num {
  double get em =>
      (ScreenUtil().screenWidth > ScreenUtil().screenHeight)
          ? sh / 128
          : sw / 96;
}

class RecordingTape extends StatefulWidget {
  final DateTime _start;
  const RecordingTape(this._start, {super.key});

  @override
  State<RecordingTape> createState() => _RecordingTapeState();
}

class _RecordingTapeState extends State<RecordingTape>
    with SingleTickerProviderStateMixin {
  late final Ticker ticker;
  Duration duration = Duration.zero;

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
    if (elapsed > Duration(milliseconds: 16) && context.mounted) {
      setState(() {
        duration = DateTime.now().difference(widget._start);
      });
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        SizedBox(width: 84.em, height: 50.em, child: Tape()),
        // tape "hole"
        Padding(
          padding: EdgeInsets.only(bottom: 2.em),
          child: Container(
            width: 50.em,
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
          child: SizedBox(width: 32.em, height: 8.em, child: SoundViz()),
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
            child: FittedBox(child: Tapewheel()),
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
            child: FittedBox(child: Tapewheel()),
          ),
        ),
        // tape title
        Positioned(
          top: 8.em,
          child: Text.rich(
            TextSpan(
              text: widget._start.toString(),
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
              text: _printDuration(duration),
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
    );
  }
}
