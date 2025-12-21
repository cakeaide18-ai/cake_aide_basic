import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cake_aide_basic/models/user_profile.dart';
import 'package:cake_aide_basic/repositories/user_profile_repository.dart';

/// Authentication state manager for CakeAide app
/// Provides a single source of truth for authentication state
class AuthStateManager extends ChangeNotifier {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal() {
    _initialize();
  }

  firebase_auth.User? _currentUser;
  UserProfile? _userProfile;
  bool _isLoading = false;
  final UserProfileRepository _profileRepo = UserProfileRepository();

  firebase_auth.User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  void _initialize() {
    try {
      // Set initial user
      _currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

      // Listen to auth state changes
      firebase_auth.FirebaseAuth.instance.authStateChanges().listen((firebase_auth.User? user) {
        _currentUser = user;
        
        if (_currentUser == null) {
          // User signed out, clear profile
          _userProfile = null;
        }
        
        notifyListeners();
      });
    } catch (e) {
      debugPrint('AuthStateManager: Firebase Auth not initialized: $e');
    }
  }

  /// Load user profile from Firestore
  /// Call this after successful authentication
  Future<void> loadUserProfile() async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _userProfile = await _profileRepo.getByUserId(_currentUser!.uid);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
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

      await firebase_auth.FirebaseAuth.instance.signOut();
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set user profile directly (for local updates)
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    if (_currentUser == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();

      await _profileRepo.updateProfile(_currentUser!.uid, profile.toMap());
      _userProfile = profile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create user profile
  Future<void> createUserProfile(UserProfile profile) async {
    if (_currentUser == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();

      await _profileRepo.setUserProfile(_currentUser!.uid, profile);
      _userProfile = profile;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}