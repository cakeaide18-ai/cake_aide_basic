import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show FrameTiming;
import 'package:firebase_core/firebase_core.dart';
import 'package:cake_aide_basic/theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:cake_aide_basic/screens/auth/login_screen.dart';
import 'package:cake_aide_basic/screens/auth/signup_screen.dart';
import 'package:cake_aide_basic/screens/profile/profile_creation_screen.dart';
import 'package:cake_aide_basic/screens/main_navigation.dart';
import 'package:cake_aide_basic/firebase_options.dart';
import 'package:cake_aide_basic/supabase/supabase_config.dart';
import 'package:cake_aide_basic/services/timer_background_service.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:cake_aide_basic/services/theme_controller.dart';
import 'package:cake_aide_basic/services/remote_logger.dart';
import 'package:cake_aide_basic/services/auth_service.dart';

Future<void> main() async {
  // Ensure Flutter is ready ASAP and show UI immediately.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Sentry. Require DSN in non-debug builds to avoid silent
  // production rollouts without observability. Provide via
  // --dart-define=SENTRY_DSN=... in CI or local runs.
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  const sentryEnv = String.fromEnvironment('SENTRY_ENV', defaultValue: 'production');
  const sentryRelease = String.fromEnvironment('GIT_SHA', defaultValue: 'unknown');
  const sentryTracesSampleRateStr = String.fromEnvironment('SENTRY_TRACES_SAMPLE_RATE', defaultValue: '0.0');
  final tracesRate = double.tryParse(sentryTracesSampleRateStr) ?? 0.0;
  const allowSendUserEmailStr = String.fromEnvironment('SENTRY_ALLOW_SEND_USER_EMAIL', defaultValue: '0');
  const allowSendUserEmail = allowSendUserEmailStr == '1';

  if (sentryDsn.isNotEmpty) {
    // Fail fast in non-debug to enforce observability configuration in CI/release.
    if (!kDebugMode && sentryDsn.isEmpty) {
      throw StateError('SENTRY_DSN is not set in release build.');
    }
    await SentryFlutter.init((options) {
      options.dsn = sentryDsn;
      options.environment = sentryEnv;
      options.release = 'cake_aide@$sentryRelease';
      options.tracesSampleRate = tracesRate;
      options.addInAppInclude('package:cake_aide_basic');

      // Scrub or modify events before sending. By default we remove
      // user.email unless explicitly allowed, and strip common auth headers.
      // Sentry 9.x: BeforeSendCallback signature is
      //   SentryEvent? Function(SentryEvent event, {Hint? hint})
      // and SentryEvent is immutable, so use copyWith.
  SentryEvent scrubEvent(SentryEvent event) {
        try {
          // Sanitize user email unless explicitly allowed.
          if (event.user != null && !allowSendUserEmail) {
            event.user = SentryUser(
              id: event.user!.id,
              username: event.user!.username,
            );
          }
          // Remove sensitive headers from request if present.
          if (event.request?.headers.isNotEmpty == true) {
            final headers = Map<String, String>.from(event.request!.headers);
            headers.remove('Authorization');
            headers.remove('Cookie');
            event.request!.headers = headers;
          }
        } catch (_) {}
        return event;
      }
      options.beforeSend = ((SentryEvent event, {dynamic hint}) {
        // Pass-through scrubber; do not drop events here.
        return scrubEvent(event);
      }) as BeforeSendCallback;
    });

    // Optional startup test capture (enable with --dart-define=SENTRY_TEST_CAPTURE=1)
    const doTest = String.fromEnvironment('SENTRY_TEST_CAPTURE', defaultValue: '0') == '1';
    if (doTest) {
      try {
        await Sentry.captureMessage('Sentry test capture from app startup');
      } catch (_) {}
    }
  }

  // Print the app origin for Firebase Authorized domains setup (web preview)
  debugPrint('App origin: ${Uri.base.origin}');
  debugPrint('[Startup] Phase=bootstrap binding ensured');

  // Register Android headless task only on Android. Skip on iOS & Web.
  if (!kIsWeb && Platform.isAndroid) {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }

  // Global error handling to avoid silent failures in release
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: \n${details.exceptionAsString()}\n${details.stack}');
    // Send to Sentry if configured
    try {
      Sentry.captureException(details.exception, stackTrace: details.stack);
    } catch (_) {}
  };
  // Render a visible error widget instead of a silent black screen.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Show detailed errors only in debug mode to avoid leaking internals in
    // production. In release, show a minimal message and ensure the full
    // details are logged so they can be picked up by remote logging.
    final String message = kDebugMode
        ? 'Something went wrong while starting the app.\n\n${details.exceptionAsString()}'
        : 'Something went wrong while starting the app.';

  // Still log full details in all builds so CI/remote logging can pick it up.
  debugPrint('FlutterError: \n${details.exceptionAsString()}\n${details.stack}');
  // Best-effort remote reporting for startup errors
  RemoteLogger.logError(details.exceptionAsString(), meta: {'stack': details.stack?.toString()});

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught zone error: $error\n$stack');
    // Best-effort remote reporting
    RemoteLogger.logError(error.toString(), meta: {'stack': stack.toString()});
    // Forward to Sentry
    try {
      Sentry.captureException(error, stackTrace: stack as StackTrace?);
    } catch (_) {}
    return true; // handled
  };

  // Start critical initialization, but don't block the first frame.
  final Future<void> initFuture = _preInitialize();
  runApp(StartupGate(initFuture: initFuture));
}

Future<void> _safeInitialization() async {
  try {
    // Firebase is already initialized pre-runApp. Only handle web redirect here.
    try {
      // Print Firebase project info to ensure Console edits target the right project
      if (Firebase.apps.isNotEmpty) {
        final projectId = Firebase.app().options.projectId;
        debugPrint('Firebase projectId: $projectId');
      }
    } catch (_) {
      // Ignore
    }
    // Handle any pending OAuth redirect sign-in (e.g., Apple on web)
    try {
      if (kIsWeb) {
        // Slight delay to ensure auth is ready
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await AuthService.handleRedirectSignInIfAny();
      }
    } catch (e) {
      debugPrint('Auth redirect handler error: $e');
    }
    
    // Supabase was initialized before runApp; skip here to avoid duplicate init.
    
    // Defer Timer Background Service until actually needed to avoid iOS launch issues
    if (kIsWeb || kDebugMode) {
      debugPrint('Timer Background Service skipped (web or debug mode)');
    }
  } catch (e) {
    debugPrint('General initialization error: $e');
    // Continue with app launch even if services fail
  }
}

// Perform critical initialization steps without blocking first paint.
Future<void> _preInitialize() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10), onTimeout: () {
      debugPrint('Firebase.initializeApp timed out; proceeding cautiously');
      return Firebase.app();
    });
    debugPrint('Firebase initialized successfully (StartupGate)');
  } catch (e, st) {
    debugPrint('Firebase initialization failed (StartupGate): $e\n$st');
  }

  try {
    await SupabaseConfig.initialize()
        .timeout(const Duration(seconds: 8), onTimeout: () {
      debugPrint('Supabase initialization timed out; continuing cautiously');
      return;
    });
    debugPrint('Supabase initialized successfully (StartupGate)');
  } catch (e) {
    debugPrint('Supabase initialization failed (StartupGate): $e');
  }

  // Post-frame follow-ups
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await ThemeController.instance
          .load()
          .timeout(const Duration(seconds: 3), onTimeout: () {
        debugPrint('ThemeController load timed out; using default theme');
        return;
      });
    } catch (e) {
      debugPrint('ThemeController load error: $e');
    }

    try {
      await _safeInitialization()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        debugPrint('App initialization timed out; continuing without some services');
        return;
      });
    } catch (e) {
      debugPrint('App initialization error (outer): $e');
    }
  });
}

// Android headless background-fetch handler
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  WidgetsFlutterBinding.ensureInitialized();
  final String taskId = task.taskId;
  final bool timeout = task.timeout;
  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }
  try {
    await TimerBackgroundService.initializeNotifications();
    await TimerBackgroundService.performBackgroundFetchOnce();
  } catch (e) {
    debugPrint('Headless background fetch error: $e');
  } finally {
    BackgroundFetch.finish(taskId);
  }
}

class CakeAideApp extends StatelessWidget {
  const CakeAideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final app = MaterialApp(
          title: 'CakeAide Pro - Cake Business Assistant',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeController.instance.themeMode,
          home: const LoginScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/profile-creation': (context) => const ProfileCreationScreen(),
            '/main': (context) => const MainNavigation(),
          },
        );
        // Wrap with a first-frame watchdog to detect and surface black-screen hangs
        return FirstFrameWatchdog(child: app);
      },
    );
  }
}

// A minimal startup gate that shows a simple splash while we initialize
// critical services on a background microtask.
class StartupGate extends StatelessWidget {
  final Future<void> initFuture;
  const StartupGate({super.key, required this.initFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _MinimalSplash();
        }
        debugPrint('[Startup] Phase=preInit complete, building app');
        return const CakeAideApp();
      },
    );
  }
}

class _MinimalSplash extends StatelessWidget {
  const _MinimalSplash();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Keep it simple and dependency-free for early paint.
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                'Starting…',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Watches for the first rendered frame and, if it doesn't arrive within a
/// timeout, overlays a simple fallback UI so users don't see a permanent black screen.
class FirstFrameWatchdog extends StatefulWidget {
  final Widget child;
  final Duration timeout;
  const FirstFrameWatchdog({super.key, required this.child, this.timeout = const Duration(seconds: 7)});

  @override
  State<FirstFrameWatchdog> createState() => _FirstFrameWatchdogState();
}

class _FirstFrameWatchdogState extends State<FirstFrameWatchdog> {
  bool _firstFrameSeen = false;
  bool _timedOut = false;
  int _attempt = 0;
  Timer? _timer;

  void _onTimings(List<FrameTiming> timings) {
    if (!_firstFrameSeen && timings.isNotEmpty) {
      _firstFrameSeen = true;
      _timer?.cancel();
      debugPrint('[Startup] First frame rasterized in ${timings.first.totalSpan.inMilliseconds}ms');
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('[Startup] FirstFrameWatchdog start attempt=$_attempt timeout=${widget.timeout.inSeconds}s');
    WidgetsBinding.instance.addTimingsCallback(_onTimings);
    _timer = Timer(widget.timeout, () {
      if (mounted && !_firstFrameSeen) {
        _timedOut = true;
        debugPrint('[Startup][Warning] No first frame after ${widget.timeout.inSeconds}s. Showing recovery overlay.');
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    // No direct removeTimingsCallback API available before 3.16; duplicate callbacks are harmless.
    super.dispose();
  }

  void _retry() {
    debugPrint('[Startup] Retry pressed; forcing subtree rebuild');
    setState(() {
      _timedOut = false;
      _firstFrameSeen = false;
      _attempt++;
    });
    // Restart the timer for the new attempt
    _timer?.cancel();
    _timer = Timer(widget.timeout, () {
      if (mounted && !_firstFrameSeen) {
        _timedOut = true;
        debugPrint('[Startup][Warning] Retry did not produce a frame within timeout.');
        setState(() {});
      }
    });
    // Nudge the pipeline to schedule a frame
    WidgetsBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: ValueKey('app-subtree-$_attempt'), child: widget.child);
    if (!_timedOut || _firstFrameSeen) return child;

    // Recovery overlay: keep it dependency-free and bright to avoid blending with black.
    return Stack(children: [
      child,
      Positioned.fill(
        child: ColoredBox(
          color: Colors.white,
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text(
                        'Still starting…',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'If this screen stays here, tap Retry to refresh the app.\nThis helps when iOS gets stuck showing a black screen on first launch.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Retry', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: const StadiumBorder()),
                          onPressed: _retry,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}
