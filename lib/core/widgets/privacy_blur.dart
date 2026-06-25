import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable widget to blur sensitive UI elements when privacy mode is enabled.
class PrivacyBlur extends StatelessWidget {
  final bool enabled;
  final Widget child;
  final double sigma;

  const PrivacyBlur({
    super.key,
    required this.enabled,
    required this.child,
    this.sigma = 6.6,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: AbsorbPointer(child: child),
    );
  }
}
