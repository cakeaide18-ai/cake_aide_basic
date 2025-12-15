import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Supabase configuration for CakeAide app
class SupabaseConfig {
  static const String supabaseUrl = 'https://mhmagibosolhgrrxxrva.supabase.co';
  // The anon key is required at build/run time and must be provided via
  // a compile-time define: `--dart-define=SUPABASE_ANON_KEY=your_key_here`.
  // This repo no longer keeps a fallback anon key in source.
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static Future<void> initialize() async {
    if (anonKey.isEmpty) {
      // Skip Supabase initialization if no key provided
      // This allows the app to run without Supabase for testing
      debugPrint('SUPABASE_ANON_KEY not provided, skipping Supabase initialization');
      return;
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
      debug: kDebugMode,
    );
  }

  static SupabaseClient? get clientOrNull {
    try {
      return Supabase.instance.client;
    } catch (e) {
      debugPrint('Supabase not initialized: $e');
      return null;
    }
  }
  
  static SupabaseClient get client {
    final c = clientOrNull;
    if (c == null) {
      throw Exception('Supabase not initialized. Call SupabaseConfig.initialize() first or provide SUPABASE_ANON_KEY');
    }
    return c;
  }
  
  static GoTrueClient get auth => client.auth;
}

/// Authentication service - Remove this class if your project doesn't need auth
class SupabaseAuth {
  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final response = await SupabaseConfig.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      // Optional: Create user profile after successful signup
      if (response.user != null) {
        await _createUserProfile(response.user!, userData);
      }

      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await SupabaseConfig.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Get current user
  static User? get currentUser => SupabaseConfig.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Auth state changes stream
  static Stream<AuthState> get authStateChanges =>
      SupabaseConfig.auth.onAuthStateChange;

  /// Create user profile in database for CakeAide app
  static Future<void> _createUserProfile(
    User user,
    Map<String, dynamic>? userData,
  ) async {
    try {
      // Check if profile already exists
      final existingUser = await SupabaseService.selectSingle(
        'user_profiles',
        filters: {'id': user.id},
      );

      if (existingUser == null) {
        await SupabaseService.insert('user_profiles', {
          'id': user.id,
          'name': userData?['name'] ?? '',
          'email': user.email ?? '',
          'phone': userData?['phone'] ?? '',
          'business_name': userData?['business_name'] ?? '',
          'location': userData?['location'] ?? '',
          'experience_level': userData?['experience_level'] ?? 'Beginner',
          'business_type': userData?['business_type'] ?? 'Home Baker',
          'bio': userData?['bio'] ?? '',
          'profile_image_url': userData?['profile_image_url'] ?? '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      // Don't throw here to avoid breaking the signup flow
    }
  }

  /// Handle authentication errors
  static String _handleAuthError(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password';
        case 'Email not confirmed':
          return 'Please check your email and confirm your account';
        case 'User not found':
          return 'No account found with this email';
        case 'Signup requires a valid password':
          return 'Password must be at least 6 characters';
        case 'Too many requests':
          return 'Too many attempts. Please try again later';
        default:
          return 'Authentication error: ${error.message}';
      }
    } else if (error is PostgrestException) {
      return 'Database error: ${error.message}';
    } else {
      return 'Network error. Please check your connection';
    }
  }
}

/// Generic database service for CRUD operations
class SupabaseService {
  /// Select multiple records from a table
  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      // Check if Supabase is initialized
      final client = SupabaseConfig.clientOrNull;
      if (client == null) {
        debugPrint('SupabaseService.select: Supabase not initialized, returning empty list');
        return [];
      }
      
      dynamic query = client.from(table).select(select ?? '*');

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query;
    } catch (e) {
      throw _handleDatabaseError('select', table, e);
    }
  }

  /// Select a single record from a table
  static Future<Map<String, dynamic>?> selectSingle(
    String table, {
    String? select,
    required Map<String, dynamic> filters,
  }) async {
    try {
      // Check if Supabase is initialized
      final client = SupabaseConfig.clientOrNull;
      if (client == null) {
        debugPrint('SupabaseService.selectSingle: Supabase not initialized, returning null');
        return null;
      }
      
      dynamic query = client.from(table).select(select ?? '*');

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      return await query.maybeSingle();
    } catch (e) {
      throw _handleDatabaseError('selectSingle', table, e);
    }
  }

  /// Insert a record into a table
  static Future<List<Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final client = SupabaseConfig.clientOrNull;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      return await client.from(table).insert(data).select();
    } catch (e) {
      throw _handleDatabaseError('insert', table, e);
    }
  }

  /// Insert multiple records into a table
  static Future<List<Map<String, dynamic>>> insertMultiple(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      final client = SupabaseConfig.clientOrNull;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      return await client.from(table).insert(data).select();
    } catch (e) {
      throw _handleDatabaseError('insertMultiple', table, e);
    }
  }

  /// Update records in a table
  static Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      final client = SupabaseConfig.clientOrNull;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      dynamic query = client.from(table).update(data);

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      return await query.select();
    } catch (e) {
      throw _handleDatabaseError('update', table, e);
    }
  }

  /// Delete records from a table
  static Future<void> delete(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      final client = SupabaseConfig.clientOrNull;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      dynamic query = client.from(table).delete();

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      await query;
    } catch (e) {
      throw _handleDatabaseError('delete', table, e);
    }
  }

  /// Get direct table reference for complex queries
  static SupabaseQueryBuilder from(String table) =>
      SupabaseConfig.client.from(table);

  /// Handle database errors
  static String _handleDatabaseError(
    String operation,
    String table,
    dynamic error,
  ) {
    if (error is PostgrestException) {
      return 'Failed to $operation from $table: ${error.message}';
    } else {
      return 'Failed to $operation from $table: ${error.toString()}';
    }
  }
}
