import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_card.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Nama tidak boleh kosong');
      return;
    }

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Email tidak boleh kosong');
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password tidak boleh kosong');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password minimal 6 karakter');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Password tidak cocok');
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .register(name: name, email: email, password: password);

      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              ref.read(authProvider).error ??
              'Registrasi gagal. Silakan coba lagi.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withOpacity(0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AppCard(
                glass: true,
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.userPlus,
                        size: 24,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Daftar Akun Baru',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat akun untuk mulai menggunakan Kasir Pro',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Error banner
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cs.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.error.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.alertCircle,
                              color: cs.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: cs.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),

                    AppInput(
                      controller: _nameController,
                      placeholder: 'Nama Lengkap',
                      prefixIcon: Icon(
                        LucideIcons.user,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _emailController,
                      placeholder: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        LucideIcons.mail,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _passwordController,
                      placeholder: 'Password',
                      obscureText: true,
                      prefixIcon: Icon(
                        LucideIcons.lock,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _confirmPasswordController,
                      placeholder: 'Konfirmasi Password',
                      obscureText: true,
                      prefixIcon: Icon(
                        LucideIcons.lock,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                      enabled: !isLoading,
                      onSubmitted: (_) => _handleRegister(),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Daftar',
                      onPressed: isLoading ? null : _handleRegister,
                      isLoading: isLoading,
                      fullWidth: true,
                      size: BtnSize.lg,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: theme.textTheme.bodySmall,
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/login'),
                          child: Text(
                            'Masuk',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.primary,
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
        ),
      ),
    );
  }
}
