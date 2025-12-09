import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';

class TimerBackgroundService {
  // Notifications
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'timer_channel';
  static const String channelName = 'Work Timer';
  static const String channelDescription = 'Notifications for work timer';

  // Preferences keys
  static const String timerStartTimeKey = 'timer_start_time';
  static const String timerActivityKey = 'timer_activity';
  static const String timerIsRunningKey = 'timer_is_running';
  static const String timerPausedTimeKey = 'timer_paused_time';

  // BGTask identifiers (iOS)
  static const String iosTaskIdRefresh = 'com.cakeaidepro.app.timer.refresh';
  static const String iosTaskIdProcessing = 'com.cakeaidepro.app.timer.processing';

  // Internal
  static bool _backgroundFetchConfigured = false;
  static bool _notificationsInitialized = false;

  // Call this to ensure the service is ready; idempotent.
  static Future<void> ensureReady() async {
    await initializeNotifications();
    await _configureBackgroundFetch();
  }

  static Future<void> initializeNotifications() async {
    if (_notificationsInitialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap if needed
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.low,
      playSound: false,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _notificationsInitialized = true;
  }

  // ----------------- Background fetch (iOS & Android) -----------------
  static Future<void> _configureBackgroundFetch() async {
    if (_backgroundFetchConfigured) return;

    // Configure periodic background fetch (min 15 minutes on iOS)
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // iOS enforces ~15 minutes minimum
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiredNetworkType: NetworkType.ANY,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout,
    );

    _backgroundFetchConfigured = true;
  }

  // Background fetch handler for iOS & Android
  static Future<void> _onBackgroundFetch(String taskId) async {
    try {
      await _performBackgroundTick();
    } catch (e) {
      debugPrint('Background fetch error: $e');
    } finally {
      // Must signal completion
      BackgroundFetch.finish(taskId);
    }
  }

  // Public wrapper for headless tasks (Android)
  static Future<void> performBackgroundFetchOnce() async {
    await _performBackgroundTick();
  }

  static void _onBackgroundFetchTimeout(String taskId) {
    // iOS gives your task ~30s; be sure to finish quickly
    BackgroundFetch.finish(taskId);
  }

  // Shared background work: update elapsed time, refresh notification
  static Future<void> _performBackgroundTick() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(timerIsRunningKey) ?? false;
    final startTimeMillis = prefs.getInt(timerStartTimeKey);
    final activity = prefs.getString(timerActivityKey) ?? 'Working';
    final pausedTimeMillis = prefs.getInt(timerPausedTimeKey) ?? 0;

    if (!isRunning || startTimeMillis == null) {
      return;
    }

    final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    final totalElapsed = elapsed - Duration(milliseconds: pausedTimeMillis);
    if (totalElapsed.inSeconds < 0) return;

    // On iOS, we don't run a 1s ticker. We just refresh the user-visible state
    // and keep a useful notification so users know the timer is active.
    await _showTimerNotification(activity, _formatDuration(totalElapsed));
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  static Future<void> _showTimerNotification(String activity, String timeElapsed) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      888,
      'CakeAide Pro Timer - $activity',
      timeElapsed,
      notificationDetails,
    );
  }

  // ----------------- Public API used by UI -----------------
  static Future<void> startTimer(String activity) async {
    // Ensure background services are ready before using them
    await ensureReady();
    final prefs = await SharedPreferences.getInstance();
    final startTime = DateTime.now().millisecondsSinceEpoch;

    await prefs.setInt(timerStartTimeKey, startTime);
    await prefs.setString(timerActivityKey, activity);
    await prefs.setBool(timerIsRunningKey, true);
    await prefs.setInt(timerPausedTimeKey, 0);

    // Configure and start background fetch for periodic updates (both platforms)
    await _configureBackgroundFetch();
    try {
      await BackgroundFetch.start();
    } catch (e) {
      debugPrint('BackgroundFetch start error: $e');
    }

    // Schedule periodic processing task to refresh the notification
    try {
      await BackgroundFetch.scheduleTask(TaskConfig(
        taskId: iosTaskIdProcessing,
        delay: 15 * 60 * 1000, // 15 min
        periodic: true,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresNetworkConnectivity: false,
        requiresCharging: false,
      ));
    } catch (e) {
      debugPrint('BackgroundFetch scheduleTask error: $e');
    }

    // Show an initial notification
    await _showTimerNotification(activity, '00:00:00');
  }

  static Future<void> pauseTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimeMillis = prefs.getInt(timerStartTimeKey);

    if (startTimeMillis != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      final currentTime = DateTime.now();
      final elapsed = currentTime.difference(startTime);
      final previousPausedTime = prefs.getInt(timerPausedTimeKey) ?? 0;

      final totalAccumulatedTime = previousPausedTime + elapsed.inMilliseconds;
      await prefs.setInt(timerPausedTimeKey, totalAccumulatedTime);
      await prefs.setBool(timerIsRunningKey, false);

    // Keep fetch configured but it will no-op when not running
    await flutterLocalNotificationsPlugin.cancel(888);
    }
  }

  static Future<void> resumeTimer() async {
    await ensureReady();
    final prefs = await SharedPreferences.getInstance();
    final newStartTime = DateTime.now().millisecondsSinceEpoch;

    await prefs.setInt(timerStartTimeKey, newStartTime);
    await prefs.setBool(timerIsRunningKey, true);

    await _configureBackgroundFetch();
    try {
      await BackgroundFetch.start();
      await BackgroundFetch.scheduleTask(TaskConfig(
        taskId: iosTaskIdProcessing,
        delay: 15 * 60 * 1000,
        periodic: true,
        stopOnTerminate: false,
        enableHeadless: true,
      ));
    } catch (e) {
      debugPrint('BackgroundFetch resume error: $e');
    }
  }

  static Future<void> stopTimer() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(timerStartTimeKey);
    await prefs.remove(timerActivityKey);
    await prefs.setBool(timerIsRunningKey, false);
    await prefs.remove(timerPausedTimeKey);

    // Stop notifications and background tasks
    await flutterLocalNotificationsPlugin.cancel(888);
    try {
      await BackgroundFetch.stop();
    } catch (e) {
      debugPrint('BackgroundFetch stop error: $e');
    }
  }

  static Future<Duration?> getCurrentDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(timerIsRunningKey) ?? false;
    final startTimeMillis = prefs.getInt(timerStartTimeKey);
    final pausedTimeMillis = prefs.getInt(timerPausedTimeKey) ?? 0;

    if (startTimeMillis != null) {
      final startTime = DateTime.fromMillisecondsSinceEpoch(startTimeMillis);
      final currentTime = DateTime.now();

      if (isRunning) {
        final elapsed = currentTime.difference(startTime);
        final totalElapsed = elapsed - Duration(milliseconds: pausedTimeMillis);
        return totalElapsed.inSeconds >= 0 ? totalElapsed : Duration.zero;
      } else {
        return Duration(milliseconds: pausedTimeMillis);
      }
    }

    return Duration.zero;
  }

  static Future<String?> getCurrentActivity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(timerActivityKey);
  }

  static Future<bool> isTimerRunning() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(timerIsRunningKey) ?? false;
  }
}