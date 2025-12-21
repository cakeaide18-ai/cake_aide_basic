import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:cake_aide_basic/supabase/cake_aide_service.dart';
import 'package:cake_aide_basic/models/user_profile.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? lastAuthErrorMessage;

  /// Sign in with Google and Firebase
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      
      if (kIsWeb) {
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        final user = userCredential.user;
        if (user != null) {
          // Attach user to Sentry (non-blocking)
          try {
            Sentry.configureScope((scope) => scope.setUser(
              SentryUser(id: user.uid, email: user.email, username: user.displayName),
            ));
            debugPrint('Google Sign-In (Web): Configured Sentry for user ${user.uid}');
          } catch (e) {
            debugPrint('Google Sign-In (Web): Failed to configure Sentry (non-fatal): $e');
          }
          
          // Sync to Supabase user profile (non-blocking)
          syncFirebaseUserToSupabase(user).catchError((e) {
            debugPrint('Google Sign-In (Web): Failed to sync to Supabase (non-fatal): $e');
          });
        }
        return user;
      } else {
        final UserCredential userCredential = await _auth.signInWithProvider(googleProvider);
        final user = userCredential.user;
        if (user != null) {
          try {
            Sentry.configureScope((scope) => scope.setUser(
              SentryUser(id: user.uid, email: user.email, username: user.displayName),
            ));
            debugPrint('Google Sign-In (Native): Configured Sentry for user ${user.uid}');
          } catch (e) {
            debugPrint('Google Sign-In (Native): Failed to configure Sentry (non-fatal): $e');
          }
          
          // Sync to Supabase user profile (non-blocking)
          syncFirebaseUserToSupabase(user).catchError((e) {
            debugPrint('Google Sign-In (Native): Failed to sync to Supabase (non-fatal): $e');
          });
        }
        return user;
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In FirebaseAuthException: code=${e.code}, message=${e.message}');
      // Set a helpful message for common misconfigurations
      if (e.code == 'unauthorized-domain') {
        final host = Uri.base.host;
        lastAuthErrorMessage =
            'Google sign-in is blocked because this domain is not authorized in Firebase Auth (domain: $host). Add it in Firebase Console → Authentication → Settings → Authorized domains.';
      } else {
        lastAuthErrorMessage = e.message ?? 'Google sign-in failed. Please try again.';
      }
      return null;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      lastAuthErrorMessage = 'Google sign-in failed: $e';
      return null;
    }
  }

  /// Sign in with Apple and Firebase
  static Future<User?> signInWithApple() async {
    try {
      // Reset last error
      lastAuthErrorMessage = null;
      // Check if available first
      if (!await isAppleSignInAvailable()) {
        debugPrint('Apple Sign-In not available on this platform');
        lastAuthErrorMessage = 'Apple Sign-In is not available on this platform.';
        return null;
      }

      if (kIsWeb) {
        // On web, prefer popup but gracefully fall back to redirect if the
        // environment (like Dreamflow Preview) triggers a JS interop type error.
        final provider = OAuthProvider('apple.com');
        provider.setCustomParameters({'locale': 'en_US'});
        try {
          final cred = await _auth.signInWithPopup(provider);
          debugPrint('Apple Web Sign-In via popup succeeded for uid=${cred.user?.uid}');
          
          // Sync to Supabase user profile (non-blocking)
          if (cred.user != null) {
            syncFirebaseUserToSupabase(cred.user!).catchError((e) {
              debugPrint('Apple Web Sign-In: Failed to sync to Supabase (non-fatal): $e');
            });
          }
          
          return cred.user;
        } on FirebaseAuthException catch (e) {
          debugPrint('Apple Web Sign-In FirebaseAuthException: code=${e.code}, message=${e.message}');
          if (e.code == 'unauthorized-domain') {
            final host = Uri.base.host;
            lastAuthErrorMessage =
                'Apple sign-in is blocked because this domain is not authorized in Firebase Auth (domain: $host). Add it in Firebase Console → Authentication → Settings → Authorized domains.';
          } else if (e.code == 'operation-not-allowed') {
            lastAuthErrorMessage =
                'Apple provider is disabled in Firebase Auth. Enable Apple in Firebase Console → Authentication → Sign-in method.';
          } else if (e.code == 'popup-blocked' || e.code == 'popup-closed-by-user') {
            // Fallback to redirect when popup is blocked/closed
            try {
              await _auth.signInWithRedirect(provider);
              debugPrint('Apple Web Sign-In falling back to redirect...');
            } catch (re) {
              debugPrint('Apple Web Redirect Sign-In error: $re');
              lastAuthErrorMessage = e.message ?? 'Apple sign-in failed. Please try again.';
            }
          } else {
            lastAuthErrorMessage = e.message ?? 'Apple sign-in failed. Please try again.';
          }
          return null;
        } catch (e) {
          // Handle non-Firebase JS interop errors (seen as LegacyJavaScriptObject in Preview)
          final msg = e.toString();
          if (msg.contains('LegacyJavaScriptObject') || msg.contains('is not a subtype')) {
            try {
              await _auth.signInWithRedirect(provider);
              debugPrint('Apple Web Sign-In encountered interop error; falling back to redirect...');
              // After redirect completes, authStateChanges will emit.
            } catch (re) {
              debugPrint('Apple Web Redirect Sign-In error: $re');
              lastAuthErrorMessage = 'Apple sign-in failed: $re';
            }
            return null;
          }
          rethrow;
        }
      } else {
        // Native (iOS/macOS): use SIWA plugin + Firebase credential with nonce
        final rawNonce = _generateNonce();
        final nonce = _sha256ofString(rawNonce);

        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: const [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          // Provide a SHA256 nonce to bind the ID token to this request
          nonce: nonce,
        );

        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);

        // Update display name if provided (non-blocking, don't fail sign-in if this fails)
        if (appleCredential.givenName != null && userCredential.user != null) {
          try {
            final displayName = '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'.trim();
            await userCredential.user!.updateDisplayName(displayName);
            debugPrint('Apple Sign-In: Updated display name to: $displayName');
          } catch (e) {
            debugPrint('Apple Sign-In: Failed to update display name (non-fatal): $e');
            // Don't fail the sign-in process if display name update fails
          }
        }

        // Attach user to Sentry (non-blocking)
        try {
          if (userCredential.user != null) {
            Sentry.configureScope((scope) => scope.setUser(
              SentryUser(
                id: userCredential.user!.uid,
                email: userCredential.user!.email,
                username: userCredential.user!.displayName,
              ),
            ));
          }
        } catch (e) {
          debugPrint('Apple Sign-In: Failed to configure Sentry (non-fatal): $e');
        }

        // Sync to Supabase user profile (non-blocking)
        if (userCredential.user != null) {
          syncFirebaseUserToSupabase(userCredential.user!).catchError((e) {
            debugPrint('Apple Sign-In: Failed to sync to Supabase (non-fatal): $e');
          });
        }

        return userCredential.user;
      }
    } catch (e) {
      debugPrint('Apple Sign-In Error: $e');
      lastAuthErrorMessage = 'Apple sign-in failed: $e';
      return null;
    }
  }

  /// Sign up with email and password
  static Future<User?> signUpWithEmail(String email, String password, String displayName) async {
    try {
      lastAuthErrorMessage = null;
      debugPrint('SignUp: Creating account for $email');
      
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // Update display name
        try {
          await user.updateDisplayName(displayName);
          await user.reload();
          debugPrint('SignUp: Updated display name to: $displayName');
        } catch (e) {
          debugPrint('SignUp: Failed to update display name (non-fatal): $e');
        }
        
        // Attach user to Sentry (non-blocking)
        try {
          Sentry.configureScope((scope) => scope.setUser(
            SentryUser(id: user.uid, email: user.email, username: displayName),
          ));
          debugPrint('SignUp: Configured Sentry for user ${user.uid}');
        } catch (e) {
          debugPrint('SignUp: Failed to configure Sentry (non-fatal): $e');
        }
        
        // Sync to Supabase user profile (non-blocking)
        syncFirebaseUserToSupabase(user).catchError((e) {
          debugPrint('SignUp: Failed to sync to Supabase (non-fatal): $e');
        });
        
        debugPrint('SignUp: Successfully created account for ${user.email}');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('SignUp Error: ${e.code} - ${e.message}');
      
      // Provide user-friendly error messages
      switch (e.code) {
        case 'email-already-in-use':
          lastAuthErrorMessage = 'An account with this email already exists.';
          break;
        case 'invalid-email':
          lastAuthErrorMessage = 'Invalid email address.';
          break;
        case 'operation-not-allowed':
        case 'internal-error':
          lastAuthErrorMessage = 'Email/Password sign-up is not enabled. Please contact support or use Google/Apple sign-in.';
          break;
        case 'weak-password':
          lastAuthErrorMessage = 'Password is too weak. Please use a stronger password.';
          break;
        default:
          lastAuthErrorMessage = e.message ?? 'Sign up failed. Please try again.';
      }
      return null;
    } catch (e) {
      debugPrint('SignUp Error: $e');
      lastAuthErrorMessage = 'Sign up failed: $e';
      return null;
    }
  }

  /// Sign in with email and password
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      lastAuthErrorMessage = null;
      debugPrint('SignIn: Attempting sign in for $email');
      
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        // Attach user to Sentry (non-blocking)
        try {
          Sentry.configureScope((scope) => scope.setUser(
            SentryUser(id: user.uid, email: user.email, username: user.displayName),
          ));
          debugPrint('SignIn: Configured Sentry for user ${user.uid}');
        } catch (e) {
          debugPrint('SignIn: Failed to configure Sentry (non-fatal): $e');
        }
        
        debugPrint('SignIn: Successfully signed in ${user.email}');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('SignIn Error: ${e.code} - ${e.message}');
      
      // Provide user-friendly error messages
      switch (e.code) {
        case 'user-not-found':
          lastAuthErrorMessage = 'No account found with this email.';
          break;
        case 'wrong-password':
          lastAuthErrorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          lastAuthErrorMessage = 'Invalid email address.';
          break;
        case 'user-disabled':
          lastAuthErrorMessage = 'This account has been disabled.';
          break;
        default:
          lastAuthErrorMessage = e.message ?? 'Sign in failed. Please try again.';
      }
      return null;
    } catch (e) {
      debugPrint('SignIn Error: $e');
      lastAuthErrorMessage = 'Sign in failed: $e';
      return null;
    }
  }

  /// Check if Apple Sign-In is available
  static Future<bool> isAppleSignInAvailable() async {
    try {
      // On web, Apple Sign-In is available
      if (kIsWeb) return true;
      
      // On mobile, check platform availability
      return await SignInWithApple.isAvailable();
    } catch (e) {
      debugPrint('Error checking Apple Sign-In availability: $e');
      return false;
    }
  }

  /// Handle pending redirect result on web (should be called after Firebase init)
  static Future<void> handleRedirectSignInIfAny() async {
    if (!kIsWeb) return;
    try {
      final result = await _auth.getRedirectResult();
      if (result.user != null) {
        debugPrint('Completed OAuth redirect sign-in for uid=${result.user!.uid}');
        
        // Sync to Supabase user profile (non-blocking)
        syncFirebaseUserToSupabase(result.user!).catchError((e) {
          debugPrint('OAuth Redirect: Failed to sync to Supabase (non-fatal): $e');
        });
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('getRedirectResult FirebaseAuthException: code=${e.code}, message=${e.message}');
      if (e.code == 'unauthorized-domain') {
        final host = Uri.base.host;
        lastAuthErrorMessage =
            'This domain is not authorized in Firebase Auth (domain: $host). Add it in Firebase Console → Authentication → Settings → Authorized domains.';
      }
    } catch (e) {
      debugPrint('getRedirectResult error: $e');
    }
  }

  // ---- Helpers for nonce hashing ----
  static String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sync Firebase user to Supabase user_profiles table
  /// Creates or updates a user profile in Supabase based on Firebase user data
  static Future<void> syncFirebaseUserToSupabase(User firebaseUser) async {
    try {
      // Check if profile already exists
      final existingProfile = await CakeAideService.getUserProfile(firebaseUser.uid);
      
      if (existingProfile == null) {
        // Create new profile with Firebase user data
        final newProfile = UserProfile(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          phone: '',
          businessName: '',
          location: '',
          experienceLevel: 'Beginner',
          businessType: 'Home Baker',
          bio: '',
          profileImageUrl: firebaseUser.photoURL ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await CakeAideService.createUserProfile(newProfile);
        debugPrint('Created Supabase profile for Firebase user ${firebaseUser.uid}');
      } else {
        // Update existing profile if Firebase has newer data
        if (firebaseUser.displayName != null && firebaseUser.displayName!.isNotEmpty && 
            existingProfile.name.isEmpty) {
          final updatedProfile = existingProfile.copyWith(
            name: firebaseUser.displayName,
            updatedAt: DateTime.now(),
          );
          await CakeAideService.updateUserProfile(updatedProfile);
          debugPrint('Updated Supabase profile name for Firebase user ${firebaseUser.uid}');
        }
      }
    } catch (e) {
      debugPrint('Error syncing Firebase user to Supabase: $e');
      // Don't throw - this is a non-fatal sync operation
    }
  }

  /// Sign out from all providers
  static Future<void> signOut() async {
    await _auth.signOut();
    Sentry.configureScope((scope) => scope.setUser(null));
  }

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}