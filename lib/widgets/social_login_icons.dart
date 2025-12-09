import 'package:flutter/material.dart';

class SocialLoginIcons {
  /// Google logo widget
  static Widget googleIcon({double size = 20}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          // Google G design
          Center(
            child: Text(
              'G',
              style: TextStyle(
                fontSize: size * 0.7,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4285F4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Apple logo widget
  static Widget appleIcon({double size = 20, Color? color}) {
    return Icon(
      Icons.apple,
      size: size,
      color: color ?? Colors.black,
    );
  }
}