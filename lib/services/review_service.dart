import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles directing users to the appropriate app store review page.
///
/// Configure your published app identifiers below:
/// - androidPackageName: The Play Store package name (e.g., com.example.app)
/// - iOSAppId: The App Store numeric ID (e.g., 1234567890)
class ReviewService {
  // App store identifiers (update here if they change in the future)
  static const String androidPackageName = 'com.cakeaide.cakeaideapp2'; // e.g., 'com.cakeaide.app'
  static const String iOSAppId = '6751550421'; // App Store numeric ID

  /// Opens the platform-appropriate store review page.
  ///
  /// Behavior:
  /// - Android: Tries market://, falls back to https://play.google.com/store/apps/details?id=...
  /// - iOS: Uses itms-apps:// for direct review, falls back to https://apps.apple.com/... with write-review.
  /// - Web/Other: If IDs are configured, opens respective web pages; otherwise shows a helpful message.
  static Future<void> openStoreReviewPage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    Uri? primary;
    Uri? fallback;

    if (kIsWeb) {
      // On web we cannot trigger native stores. Try Play Store then App Store.
      final play = Uri.parse('https://play.google.com/store/apps/details?id=$androidPackageName');
      final appStore = Uri.parse('https://apps.apple.com/app/id$iOSAppId?action=write-review');
      final okPlay = await _tryLaunch(play);
      if (!okPlay) {
        final okAppStore = await _tryLaunch(appStore);
        if (!okAppStore) {
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Could not open store page.'),
              backgroundColor: errorColor,
            ),
          );
        }
      }
      return;
    }

    // For non-web, use TargetPlatform to avoid dart:io Platform import.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        primary = Uri.parse('market://details?id=$androidPackageName');
        fallback = Uri.parse('https://play.google.com/store/apps/details?id=$androidPackageName');
        break;
      case TargetPlatform.iOS:
        primary = Uri.parse('itms-apps://itunes.apple.com/app/id$iOSAppId?action=write-review');
        fallback = Uri.parse('https://apps.apple.com/app/id$iOSAppId?action=write-review');
        break;
      default:
        // Other platforms (macOS, Windows, Linux) – try opening web links if configured.
        primary = Uri.parse('https://play.google.com/store/apps/details?id=$androidPackageName');
        fallback = Uri.parse('https://apps.apple.com/app/id$iOSAppId?action=write-review');
    }

    final launched = await _tryLaunch(primary);
    if (!launched) {
      final ok = await _tryLaunch(fallback);
      if (!ok) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Could not open store page.'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  static Future<bool> _tryLaunch(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
