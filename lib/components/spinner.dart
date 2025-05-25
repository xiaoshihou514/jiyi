import 'dart:async';

import 'package:flutter/material.dart';

class Spinner extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  const Spinner(this.icon, this.color, this.size, {super.key});

  @override
  State<Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> {
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
      duration: const Duration(milliseconds: 16),
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}
