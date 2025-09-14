import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:school_core/school_core.dart';
import 'package:school_core/models/auth_result.dart' as core_auth;
import 'package:school_core/models/user.dart' show UserRole;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailOrUsernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  Future<void> _handleLogin() async {
    print('🚀 DEBUG: Login attempt started');
    if (!_formKey.currentState!.validate()) {
      print('❌ DEBUG: Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final emailOrUsername = _emailOrUsernameController.text.trim();
      final password = _passwordController.text;

      print('📝 DEBUG: Login input - EmailOrUsername: "$emailOrUsername"');
      print('🔑 DEBUG: Password length: ${password.length}');
      print('🔍 DEBUG: Auth service type: ${authService.runtimeType}');

      core_auth.AuthResult? result;

      // Determine login method based on input format
      if (emailOrUsername.contains('@')) {
        print('📧 DEBUG: Detected email format, using signInWithEmail');
        // Email login
        result = await authService.signInWithEmail(emailOrUsername, password);
      } else if (emailOrUsername.length >= 5 &&
          !emailOrUsername.contains(' ') &&
          !emailOrUsername.contains('@')) {
        print(
          '🔐 DEBUG: Detected access code format, using signInWithAccessCode',
        );
        // Access code login
        result = await authService.signInWithAccessCode(
          emailOrUsername,
          password,
        );
      } else {
        print('👤 DEBUG: Detected username format, using signInWithUsername');
        // Username login
        result = await authService.signInWithUsername(
          emailOrUsername,
          password,
        );
      }

      print('📊 DEBUG: Authentication result received');
      print('✅ DEBUG: Result success: ${result?.success}');
      print('👤 DEBUG: Result user exists: ${result?.user != null}');
      print('💬 DEBUG: Result message: ${result?.message}');

      if (result?.user != null) {
        print('👤 DEBUG: User role: ${result!.user!.role}');
        print('📧 DEBUG: User email: ${result.user!.email}');
      }

      if (result != null && result.success && result.user != null) {
        // Check if user is super admin
        if (result!.user!.role == UserRole.superAdmin) {
          print('🎉 DEBUG: Super admin login successful, navigating to home');
          // Navigate to home screen
          if (mounted) {
            context.go('/home');
          }
        } else {
          print('❌ DEBUG: User is not super admin, access denied');
          setState(() {
            _errorMessage = 'Access denied. Super admin privileges required.';
          });
          // Sign out the user since they don't have the right role
          await authService.signOut();
        }
      } else {
        print('❌ DEBUG: Authentication failed');
        setState(() {
          _errorMessage = result?.message ?? 'Login failed';
        });
      }
    } catch (e) {
      print('💥 DEBUG: Exception in _handleLogin: ${e.toString()}');
      print('📍 DEBUG: Exception type: ${e.runtimeType}');
      if (e is Error) {
        print('📍 DEBUG: Stack trace: ${e.stackTrace}');
      }
      setState(() {
        _errorMessage = 'Login failed: ${e.toString()}';
      });
    } finally {
      print('🏁 DEBUG: Login attempt completed');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 64,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Super Admin Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailOrUsernameController,
                      decoration: const InputDecoration(
                        labelText: 'Email / Username / Access Code',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email, username, or access code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 16)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
