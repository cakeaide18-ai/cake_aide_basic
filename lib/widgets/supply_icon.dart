import 'package:flutter/material.dart';

/// A reusable Supply icon that loads a custom PNG asset if available,
/// and gracefully falls back to a material icon when the asset is missing.
class SupplyIcon extends StatelessWidget {
  const SupplyIcon({super.key, this.size = 24, this.fallbackColor});

  /// Visual size of the icon/image.
  final double size;

  /// Optional color for the fallback material icon only.
  final Color? fallbackColor;

  static const String _assetPath = 'assets/images/supply_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        // If the asset is not in assets/images/, use a sensible fallback
        return Icon(
          Icons.inventory_2,
          size: size,
          color: fallbackColor ?? Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
