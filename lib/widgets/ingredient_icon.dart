import 'package:flutter/material.dart';

/// A reusable Ingredient icon that loads a custom PNG asset if available,
/// and gracefully falls back to a material icon when the asset is missing.
class IngredientIcon extends StatelessWidget {
  const IngredientIcon({super.key, this.size = 24, this.fallbackColor});

  /// Visual size of the icon/image.
  final double size;

  /// Optional color for the fallback material icon only.
  final Color? fallbackColor;

  static const String _assetPath = 'assets/images/ingredient_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        // If the asset is not yet added to assets/images/, use a sensible fallback
        return Icon(
          Icons.kitchen,
          size: size,
          color: fallbackColor ?? Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
