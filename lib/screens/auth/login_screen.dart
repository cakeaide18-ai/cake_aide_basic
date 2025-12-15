import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cake_aide_basic/screens/auth/signup_screen.dart';
import 'package:cake_aide_basic/screens/main_navigation.dart';
import 'package:cake_aide_basic/services/logo_service.dart';
import 'package:cake_aide_basic/services/auth_service.dart';
import 'package:cake_aide_basic/widgets/social_login_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  Stream<User?>? _authStream;
  late final StreamSubscription<User?> _authSub;

  @override
  void initState() {
    super.initState();
    // Navigate automatically when auth state becomes signed in (handles web redirect flows)
    _authStream = AuthService.authStateChanges;
    _authSub = _authStream!.listen((user) {
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Simple validation - in real app, this would connect to backend
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    }
  }

  void _loginWithGoogle() async {
    final user = await AuthService.signInWithGoogle();
    if (!mounted) return;
    
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      final message = AuthService.lastAuthErrorMessage ?? 'Google sign-in failed. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _loginWithApple() async {
    try {
      debugPrint('LoginScreen: Starting Apple Sign In');
      final user = await AuthService.signInWithApple();
      debugPrint('LoginScreen: Apple Sign In completed, user: ${user?.uid}');
      
      if (!mounted) {
        debugPrint('LoginScreen: Widget not mounted, skipping navigation');
        return;
      }
      
      if (user != null) {
        debugPrint('LoginScreen: Navigating to MainNavigation');
        // Note: The auth state listener will also trigger navigation,
        // but Navigator handles duplicate routes gracefully
        try {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainNavigation()),
          );
          debugPrint('LoginScreen: Navigation completed successfully');
        } catch (e, st) {
          debugPrint('LoginScreen: Navigation failed: $e\n$st');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigation error: $e')),
            );
          }
        }
      } else {
        final message = AuthService.lastAuthErrorMessage ?? 'Apple sign-in failed. Please try again.';
        debugPrint('LoginScreen: Apple Sign In failed: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e, st) {
      debugPrint('LoginScreen: Apple Sign In error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // App Logo
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: LogoService.getLogoWidget(
                    width: 120,
                    height: 120,
                    isCircular: true,
                  ),
                ),

                const SizedBox(height: 32),

                // Welcome Text
                Text(
                  'Welcome to CakeAide Pro',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your cake business companion',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),

                const SizedBox(height: 48),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: const Text(
                      'Sign In',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Or divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3))),
                  ],
                ),

                const SizedBox(height: 16),

                // Social Login Buttons
                Column(
                  children: [
                    // Apple Sign In (iOS only)
                    FutureBuilder<bool>(
                      future: AuthService.isAppleSignInAvailable(),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _loginWithApple,
                                  icon: SocialLoginIcons.appleIcon(size: 18, color: Colors.white),
                                  label: const Text('Continue with Apple'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // Google Sign In
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loginWithGoogle,
                        icon: SocialLoginIcons.googleIcon(size: 18),
                        label: const Text('Continue with Google'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
