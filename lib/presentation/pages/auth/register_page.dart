import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_card.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

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
                      child: Icon(LucideIcons.userPlus, size: 24, color: cs.primary),
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
                    AppInput(
                      placeholder: 'Nama Lengkap',
                      prefixIcon: Icon(
                        LucideIcons.user,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      placeholder: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(
                        LucideIcons.mail,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      placeholder: 'Password',
                      obscureText: true,
                      prefixIcon: Icon(
                        LucideIcons.lock,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      placeholder: 'Konfirmasi Password',
                      obscureText: true,
                      prefixIcon: Icon(
                        LucideIcons.lock,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Daftar',
                      onPressed: () => context.go('/login'),
                      fullWidth: true,
                      size: BtnSize.lg,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah punya akun? ', style: theme.textTheme.bodySmall),
                        TextButton(
                          onPressed: () => context.go('/login'),
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

