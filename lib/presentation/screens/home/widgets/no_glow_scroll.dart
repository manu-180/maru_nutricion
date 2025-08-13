import 'package:flutter/material.dart';

class NoGlowScroll extends ScrollBehavior {
  const NoGlowScroll();
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
