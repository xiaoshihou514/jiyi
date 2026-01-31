import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:jiyi/pages/default_colors.dart';

class AppLifecycleOverlay extends StatefulWidget {
  const AppLifecycleOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<AppLifecycleOverlay> createState() => _AppLifecycleOverlayState();
}

class _AppLifecycleOverlayState extends State<AppLifecycleOverlay>
    with WidgetsBindingObserver {
  bool shouldBlur = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final newState =
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused;
    if (shouldBlur != newState) {
      setState(() => shouldBlur = newState);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      widget.child,
      if (shouldBlur)
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: DefaultColors.bg.withValues(alpha: 0.8),
          ),
        ),
    ],
  );
}
