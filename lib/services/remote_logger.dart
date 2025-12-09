import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Minimal remote logging helper. By default this prints to the console.
/// If you set the compile-time define `REMOTE_LOG_URL` to an HTTP endpoint,
/// this will attempt to POST JSON payloads to that URL.
class RemoteLogger {
  static Future<void> logError(String message, {Map<String, dynamic>? meta}) async {
    final payload = {'message': message, 'meta': meta ?? {}, 'timestamp': DateTime.now().toIso8601String()};
    debugPrint('RemoteLogger: $payload');

    const url = String.fromEnvironment('REMOTE_LOG_URL', defaultValue: '');
    if (url.isEmpty) return;

    try {
      final uri = Uri.parse(url);
      final client = HttpClient();
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(utf8.encode(jsonEncode(payload)));
      final resp = await req.close();
      // Drain response to complete request
      await resp.drain();
      client.close();
    } catch (e) {
      debugPrint('RemoteLogger: failed to send log: $e');
    }

    // Forward to Sentry if configured
    try {
      await Sentry.captureMessage(message, level: SentryLevel.error);
    } catch (_) {}
  }
}
