import 'package:flutter/material.dart';

/// A reusable Unit Converter icon that loads a custom PNG asset if available,
/// and gracefully falls back to a material icon when the asset is missing.
class UnitConverterIcon extends StatelessWidget {
  const UnitConverterIcon({super.key, this.size = 24, this.fallbackColor});

  final double size;
  final Color? fallbackColor;

  static const String _assetPath = 'assets/images/unit_converter_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        return Icon(
          Icons.straighten,
          size: size,
          color: fallbackColor ?? Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
