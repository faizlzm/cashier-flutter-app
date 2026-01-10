import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/responsive_utils.dart';
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
    final isCompactHeight = context.isCompactHeight;
    final isLandscape = context.isLandscape;

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
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isCompactHeight ? 12 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isLandscape ? 600 : 400),
              child: AppCard(
                glass: true,
                padding: EdgeInsets.all(isCompactHeight ? 16 : 32),
                child: Form(
                  key: _formKey,
                  child: isLandscape && isCompactHeight
                      ? _buildLandscapeLayout(theme, cs, isLoading)
                      : _buildPortraitLayout(theme, cs, isLoading),
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
        color: cs.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.error.withOpacity(0.3)),
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

  Widget _buildLandscapeLayout(
    ThemeData theme,
    ColorScheme cs,
    bool isLoading,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - branding
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(LucideIcons.lock, size: 20, color: cs.primary),
              ),
              const SizedBox(height: 12),
              Text(
                'Selamat Datang!',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Kasir Pro - Solusi Modern',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right side - form
        Expanded(
          flex: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildErrorBanner(cs),
              AppInput(
                controller: _emailController,
                placeholder: 'Email',
                prefixIcon: Icon(
                  LucideIcons.mail,
                  size: 16,
                  color: cs.onSurface.withOpacity(0.4),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
              ),
              const SizedBox(height: 12),
              AppInput(
                controller: _passwordController,
                placeholder: 'Password',
                obscureText: true,
                prefixIcon: Icon(
                  LucideIcons.lock,
                  size: 16,
                  color: cs.onSurface.withOpacity(0.4),
                ),
                enabled: !isLoading,
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Masuk',
                onPressed: isLoading ? null : _handleLogin,
                isLoading: isLoading,
                fullWidth: true,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.go('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Lupa Password?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading ? null : () => context.go('/register'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Daftar Baru',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(ThemeData theme, ColorScheme cs, bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(LucideIcons.lock, size: 24, color: cs.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'Selamat Datang!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Solusi Kasir Modern untuk Bisnis Anda',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildErrorBanner(cs),
        AppInput(
          controller: _emailController,
          placeholder: 'Email',
          prefixIcon: Icon(
            LucideIcons.mail,
            size: 18,
            color: cs.onSurface.withOpacity(0.4),
          ),
          keyboardType: TextInputType.emailAddress,
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
          onSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Masuk',
          onPressed: isLoading ? null : _handleLogin,
          isLoading: isLoading,
          fullWidth: true,
          size: BtnSize.lg,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => context.go('/forgot-password'),
              child: Text(
                'Lupa Password?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : () => context.go('/register'),
              child: Text(
                'Daftar Baru',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
