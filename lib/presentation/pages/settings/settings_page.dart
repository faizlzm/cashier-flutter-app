import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = UserRepository().getCurrentUser();
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final isMobile = context.isMobile;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengaturan',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Profile Card with responsive form
              _card(
                context,
                LucideIcons.user,
                'Profil Pengguna',
                'Informasi akun anda saat ini',
                isMobile
                    ? Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Nama Lengkap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              AppInput(placeholder: user.name, readOnly: true),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              AppInput(placeholder: user.email, readOnly: true),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              AppInput(placeholder: user.role.toUpperCase(), readOnly: true),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Nama Lengkap', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    AppInput(placeholder: user.name, readOnly: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    AppInput(placeholder: user.email, readOnly: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Role', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    AppInput(placeholder: user.role.toUpperCase(), readOnly: true),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // Theme Card with responsive layout
              _card(
                context,
                LucideIcons.moon,
                'Tampilan Aplikasi',
                'Sesuaikan tampilan aplikasi dengan preferensi anda',
                isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mode Gelap', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(
                                'Aktifkan mode gelap untuk kenyamanan mata',
                                style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            text: isDark ? 'Light' : 'Dark',
                            icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 16),
                            variant: BtnVariant.outline,
                            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mode Gelap', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(
                                'Aktifkan mode gelap untuk kenyamanan mata',
                                style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                          AppButton(
                            text: isDark ? 'Light' : 'Dark',
                            icon: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 16),
                            variant: BtnVariant.outline,
                            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // Security Card
              _card(
                context,
                LucideIcons.lock,
                'Keamanan',
                null,
                AppButton(
                  text: 'Ubah Password',
                  variant: BtnVariant.outline,
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 24),

              // Logout Button
              AppButton(
                text: 'Keluar Aplikasi',
                icon: const Icon(LucideIcons.logOut, size: 18),
                variant: BtnVariant.destructive,
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, IconData icon, String title, String? subtitle, Widget content) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: isMobile ? 12 : 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }
}
