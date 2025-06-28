import 'dart:ui';
import 'package:flutter/material.dart';

class ScrollWithTouch extends StatelessWidget {
  final Widget child;

  const ScrollWithTouch({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: child,
    );
  }
}
