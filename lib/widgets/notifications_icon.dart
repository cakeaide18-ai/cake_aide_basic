import 'package:flutter/material.dart';

/// Notifications icon that prefers a custom PNG asset and
/// gracefully falls back to a Material icon with theme color.
class NotificationsIcon extends StatelessWidget {
  const NotificationsIcon({super.key, this.size = 24, this.fallbackColor});

  final double size;
  final Color? fallbackColor;

  static const String _assetPath = 'assets/images/notifications_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) {
        return Icon(
          Icons.notifications_none,
          size: size,
          color: fallbackColor ?? Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
