import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cake_aide_basic/supabase/supabase_config.dart';
import 'package:cake_aide_basic/models/user_profile.dart';
import 'package:cake_aide_basic/supabase/cake_aide_service.dart';

/// Authentication state manager for CakeAide app
/// Provides a single source of truth for authentication state
class AuthStateManager extends ChangeNotifier {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal() {
    _initialize();
  }

  User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void _initialize() {
    // Set initial user
    _currentUser = SupabaseAuth.currentUser;

    // Listen to auth state changes
    SupabaseAuth.authStateChanges.listen((AuthState data) {
      _currentUser = data.session?.user;
      
      if (_currentUser == null) {
        // User signed out, clear profile
        _userProfile = null;
      }
      
      notifyListeners();
    });
  }

  /// Load user profile from database
  /// Call this after successful authentication
  Future<void> loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _userProfile = await CakeAideService.getUserProfile(_currentUser!.id);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await SupabaseAuth.signUp(
        email: email,
        password: password,
        userData: userData,
      );

      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await SupabaseAuth.signIn(
        email: email,
        password: password,
      );

      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await SupabaseAuth.signOut();
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await SupabaseAuth.resetPassword(email);
  }

  /// Set user profile directly (for local updates)
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userProfile = await CakeAideService.updateUserProfile(profile);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create user profile
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      _isLoading = true;
      notifyListeners();

      _userProfile = await CakeAideService.createUserProfile(profile);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}