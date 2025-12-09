import 'package:flutter/material.dart';

/// A reusable Timer icon that loads a custom PNG asset if available,
/// and gracefully falls back to a material icon when the asset is missing.
class TimerIcon extends StatelessWidget {
  const TimerIcon({super.key, this.size = 24, this.fallbackColor});

  final double size;
  final Color? fallbackColor;

  static const String _assetPath = 'assets/images/timer_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        return Icon(
          Icons.timer,
          size: size,
          color: fallbackColor ?? Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
