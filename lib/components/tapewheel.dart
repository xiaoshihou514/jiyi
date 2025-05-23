import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jiyi/pages/default_colors.dart';
import 'package:jiyi/utils/stop_model.dart';

class Tapewheel extends StatefulWidget {
  final StopModel _stop;
  const Tapewheel(this._stop, {super.key});

  @override
  State<Tapewheel> createState() => _TapewheelState();
}

class _TapewheelState extends State<Tapewheel> {
  late final Timer timer;
  double turn = 0.0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 16), (Timer t) => _tick());
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void _tick() {
    if (!widget._stop.value && context.mounted) {
      setState(() {
        turn += 0.01;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: turn,
      duration: const Duration(milliseconds: 16),
      child: Icon(Icons.settings, color: DefaultColors.bg),
    );
  }
}
