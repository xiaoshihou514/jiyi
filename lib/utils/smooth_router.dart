import 'package:flutter/material.dart';

abstract class SmoothRouter {
  static PageRouteBuilder builder(Widget page) => PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween(
            begin: Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.ease)),
        ),
        child: child,
      );
    },
  );
}
