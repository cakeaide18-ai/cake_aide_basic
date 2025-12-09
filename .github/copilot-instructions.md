## CakeAide — Quick instructions for AI coding agents

This repo is a Flutter app (mobile + web) that uses Firebase (Firestore + Auth) and Supabase for backend data. The goal of these notes is to help an AI agent be immediately productive by pointing to the important files, architectural patterns, and concrete examples of how to change or extend the project.

Key files / entry points
- `lib/main.dart` — app bootstrap and safe initialization. Note the `StartupGate` and `_preInitialize()` flow: Firebase and Supabase are initialized here with timeouts and won't block first-frame rendering.
- `lib/firebase_options.dart` — generated Firebase options used by `Firebase.initializeApp(...)`.
- `lib/supabase/supabase_config.dart` — Supabase initialization (URL + anon key) and `SupabaseService` CRUD helpers.
- `lib/repositories/firebase_repository.dart` — base Firestore repository used across the app. Enforces owner-based queries and sets `created_at` / `updated_at` server timestamps.
- `lib/firestore/firestore_data_schema.dart` — canonical collection names and field name constants (use these everywhere instead of string literals).
- `lib/screens/` and `lib/widgets/` — UI is split across these folders; `lib/screens/main_navigation.dart` shows the app's navigation pattern (bottom nav + more dialog).

Architecture & conventions (concrete, discoverable)
- Two backends: Firebase (primary Firestore collections) and Supabase (has a separate `user_profiles` table and generic `SupabaseService`). See `SupabaseConfig` for the public anon key and methods.
- Ownership model: Firestore documents are scoped to a user via `FirestoreFields.ownerId`. The `FirebaseRepository` class automatically adds `owner_id` on add() and filters on queries by `owner_id`.
- Schema-first: Field/collection names live in `lib/firestore/firestore_data_schema.dart`. Always reference these constants to avoid mismatches.
- Initialization patterns: heavy work is deferred — main uses `StartupGate` and post-frame callbacks. Timeouts guard remote inits (Firebase / Supabase). If you change startup behavior, mirror the timeout and non-blocking patterns to avoid black-screen hangs (see `FirstFrameWatchdog` in `main.dart`).
- Background tasks: Android-only headless background handler registered in `main.dart` (`backgroundFetchHeadlessTask`). Background logic lives in `lib/services/timer_background_service.dart`.

Examples for common tasks
- Add a new Firestore-backed model:
  1. Add collection name and fields to `lib/firestore/firestore_data_schema.dart`.
  2. Create a model class in `lib/models/` and a repository that extends `FirebaseRepository<T>` using the collection name and toMap/fromMap converters.
  3. Use `repo.getStream()` or `repo.getAll()` — these are already scoped to the current authenticated user.

- Read/Write pattern:
  - Add: `repo.add(item)` -> `FirebaseRepository` will add `owner_id`, `created_at`, `updated_at`.
  - Query: use `repo.query()` to build additional where/ordering and pass into `getWithQuery(...)` / `getStreamWithQuery(...)`.

Developer workflows (what actually works here)
- Install dependencies: `flutter pub get` from repo root.
- Run (mobile simulator/device): `flutter run` (or specify `-d <deviceId>`). Main entry is `lib/main.dart` as usual.
- Build APK / iOS: `flutter build apk` or `flutter build ios`. For iOS, open `ios/Runner.xcworkspace` and run CocoaPods if needed (`cd ios && pod install`) before opening in Xcode.
- Web preview: `flutter run -d chrome`. Note `main.dart` prints `App origin: ${Uri.base.origin}` which helps with Firebase authorized domains for web testing.

Repository-specific gotchas & checks
- Secrets: `lib/supabase/supabase_config.dart` contains a public anon key and URL. The anon key is expected to be public for client usage; do not attempt to move it to a server secret without coordinating Supabase policies.
- Auth gating: `FirebaseRepository` methods throw if `currentUserId` is null (unauthenticated). Calls should ensure a signed-in user or gracefully handle the exception.
- Server timestamps: `add()` and `update()` use `FieldValue.serverTimestamp()` for created/updated timestamps; tests or patches that rely on client DateTimes should be adjusted accordingly.
- Background tasks: headless background fetch is registered only on Android (guarded by Platform.isAndroid) — do not assume Android behaviors run on iOS.

Where to look when things break
- App startup hangs / black screen: inspect `FirstFrameWatchdog` and `_preInitialize()` timeouts in `lib/main.dart`.
- Data mismatch / missing fields: check `lib/firestore/firestore_data_schema.dart` and repository `toMap/fromMap` converters.
- Auth redirect issues on web: `AuthService.handleRedirectSignInIfAny()` is called in `_safeInitialization()`; see `lib/services/auth_service.dart` for details.

If you change or add files, prefer small, isolated commits and reference these files in commit messages (e.g. `feat: add ingredients repo + model — uses FirestoreCollections.ingredients`).

If anything here is unclear or you'd like me to expand a specific section (examples for creating a repository, wiring a new screen, or more exact build steps for CI), tell me which area and I'll iterate.
