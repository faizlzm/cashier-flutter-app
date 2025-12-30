import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_card.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      if (mounted) context.go('/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isCompactHeight = context.isCompactHeight;
    final isLandscape = context.isLandscape;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cs.primary.withOpacity(0.1), theme.scaffoldBackgroundColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: isCompactHeight ? 12 : 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLandscape ? 600 : 400,
              ),
              child: AppCard(
                glass: true,
                padding: EdgeInsets.all(isCompactHeight ? 16 : 32),
                child: isLandscape && isCompactHeight
                    ? _buildLandscapeLayout(theme, cs)
                    : _buildPortraitLayout(theme, cs),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(ThemeData theme, ColorScheme cs) {
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
              AppInput(
                controller: _emailController,
                placeholder: 'Email: admin@kasirpro.com',
                prefixIcon: Icon(
                  LucideIcons.mail,
                  size: 16,
                  color: cs.onSurface.withOpacity(0.4),
                ),
                keyboardType: TextInputType.emailAddress,
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
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Masuk',
                onPressed: _handleLogin,
                isLoading: _isLoading,
                fullWidth: true,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => context.go('/forgot-password'),
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
                    onPressed: () => context.go('/register'),
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

  Widget _buildPortraitLayout(ThemeData theme, ColorScheme cs) {
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
        AppInput(
          controller: _emailController,
          placeholder: 'Email: admin@kasirpro.com',
          prefixIcon: Icon(
            LucideIcons.mail,
            size: 18,
            color: cs.onSurface.withOpacity(0.4),
          ),
          keyboardType: TextInputType.emailAddress,
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(value: false, onChanged: (v) {}),
            ),
            const SizedBox(width: 8),
            Text(
              'Ingat Saya',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppButton(
          text: 'Masuk',
          onPressed: _handleLogin,
          isLoading: _isLoading,
          fullWidth: true,
          size: BtnSize.lg,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => context.go('/forgot-password'),
              child: Text(
                'Lupa Password?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/register'),
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
