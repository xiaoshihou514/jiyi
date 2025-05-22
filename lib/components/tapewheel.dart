import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jiyi/pages/default_colors.dart';

class Tapewheel extends StatefulWidget {
  const Tapewheel({super.key});

  @override
  State<Tapewheel> createState() => _TapewheelState();
}

class _TapewheelState extends State<Tapewheel>
    with SingleTickerProviderStateMixin {
  double turn = 0.0;
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
    if (context.mounted) {
      setState(() {
        turn += 0.01;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turn,
      duration: const Duration(seconds: 1),
      child: Icon(Icons.settings, color: DefaultColors.bg),
    );
  }
}
