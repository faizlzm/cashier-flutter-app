import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_card.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear previous errors
    setState(() => _errorMessage = null);

    // Validate form
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Email tidak boleh kosong');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password tidak boleh kosong');
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .login(email: email, password: password);

      // Navigation is handled by router redirect
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              ref.read(authProvider).error ?? 'Login gagal. Silakan coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // final isCompactHeight = context.isCompactHeight; // Unused
    // final isLandscape = context.isLandscape; // Unused

    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Light blue-gray background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AppCard(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        LucideIcons.lock,
                        size: 32,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Masuk ke Akun Anda',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan email dan password untuk masuk.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _buildErrorBanner(cs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMAIL',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppInput(
                          controller: _emailController,
                          placeholder: 'admin@kasipro.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(
                            LucideIcons.mail,
                            size: 18,
                            color: const Color.fromARGB(255, 180, 180, 180),
                          ),
                          enabled: !isLoading,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PASSWORD',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AppInput(
                          controller: _passwordController,
                          placeholder: '•••••••',
                          obscureText: !_isPasswordVisible,
                          prefixIcon: Icon(
                            LucideIcons.lock,
                            size: 18,
                            color: const Color.fromARGB(255, 180, 180, 180),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? LucideIcons.eye
                                  : LucideIcons.eyeOff,
                              size: 18,
                              color: const Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          enabled: !isLoading,
                          onSubmitted: (_) => _handleLogin(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Masuk',
                      onPressed: isLoading ? null : _handleLogin,
                      isLoading: isLoading,
                      fullWidth: true,
                      size: BtnSize.lg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme cs) {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertCircle, color: cs.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: cs.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
