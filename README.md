# cake_aide_basic

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local configuration

This project reads the Supabase anon key from a compile-time define if set. By default the project contains a fallback anon key in `lib/supabase/supabase_config.dart`.

This project requires the Supabase anon key to be provided at build time.

Provide the key explicitly using `--dart-define`:

```bash
# Run locally
flutter run --dart-define=SUPABASE_ANON_KEY=your_key_here

# Build for release/profile
flutter build apk --dart-define=SUPABASE_ANON_KEY=your_key_here
```

Note: the repository no longer contains a fallback anon key in source. This
prevents accidental use of an embedded key and encourages explicit configuration
for different environments.


