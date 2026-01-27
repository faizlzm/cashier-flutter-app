import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/business_settings.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/business_settings_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _taxController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _taxController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final user = UserRepository().getCurrentUser();
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
    final isMobile = context.isMobile;
    final businessSettingsAsync = ref.watch(businessSettingsProvider);

    // Sync controllers with data when not editing
    businessSettingsAsync.whenData((settings) {
      if (settings != null && !_isEditing) {
        if (_nameController.text != settings.businessName) {
          _nameController.text = settings.businessName ?? '';
        }
        if (_addressController.text != settings.address) {
          _addressController.text = settings.address ?? '';
        }
        if (_taxController.text != settings.taxRate.toString()) {
          _taxController.text = settings.taxRate.toString();
        }
      }
    });

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

              // Profile Card
              _card(
                context,
                LucideIcons.user,
                'Profil Pengguna',
                'Informasi akun anda saat ini',
                isMobile
                    ? Column(
                        children: [
                          _buildProfileField('Nama Lengkap', user.name),
                          const SizedBox(height: 16),
                          _buildProfileField('Email', user.email),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildProfileField(
                                  'Nama Lengkap',
                                  user.name,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildProfileField('Email', user.email),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),

              // Business Settings Card
              _card(
                context,
                LucideIcons.building,
                'Pengaturan Bisnis',
                'Kelola informasi toko dan tarif pajak',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!_isEditing)
                      AppButton(
                        text: 'Ubah',
                        icon: const Icon(LucideIcons.pencil, size: 16),
                        variant: BtnVariant.ghost,
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    businessSettingsAsync.when(
                      data: (settings) => Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nama Toko',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                AppInput(
                                  controller: _nameController,
                                  placeholder: 'Contoh: Toko Kopi Senja',
                                  readOnly: !_isEditing,
                                  enabled: _isEditing,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Alamat',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                AppInput(
                                  controller: _addressController,
                                  placeholder: 'Alamat lengkap toko',
                                  readOnly: !_isEditing,
                                  enabled: _isEditing,
                                  textInputAction: TextInputAction.newline,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tarif Pajak (%)',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 8),
                                AppInput(
                                  controller: _taxController,
                                  placeholder: '11',
                                  readOnly: !_isEditing,
                                  enabled: _isEditing,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                            if (_isEditing) ...[
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AppButton(
                                    text: 'Batal',
                                    variant: BtnVariant.ghost,
                                    onPressed: () {
                                      setState(() {
                                        _isEditing = false;
                                        // Reset fields will happen via provider listener or re-render
                                        ref.invalidate(
                                          businessSettingsProvider,
                                        );
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  AppButton(
                                    text: 'Simpan',
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {
                                        try {
                                          final newSettings = BusinessSettings(
                                            id: settings?.id ?? '',
                                            businessName: _nameController.text,
                                            address: _addressController.text,
                                            taxRate:
                                                double.tryParse(
                                                  _taxController.text,
                                                ) ??
                                                0,
                                          );
                                          await ref
                                              .read(
                                                businessSettingsProvider
                                                    .notifier,
                                              )
                                              .updateSettings(newSettings);
                                          if (!mounted) return;
                                          setState(() {
                                            _isEditing = false;
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Pengaturan berhasil disimpan',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Gagal menyimpan: $e',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Text('Error: $err'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Theme Card
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
                              const Text(
                                'Mode Gelap',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aktifkan mode gelap untuk kenyamanan mata',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            text: isDark ? 'Light' : 'Dark',
                            icon: Icon(
                              isDark ? LucideIcons.sun : LucideIcons.moon,
                              size: 16,
                            ),
                            variant: BtnVariant.outline,
                            onPressed: () => ref
                                .read(themeModeProvider.notifier)
                                .toggleTheme(),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mode Gelap',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Aktifkan mode gelap untuk kenyamanan mata',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                          AppButton(
                            text: isDark ? 'Light' : 'Dark',
                            icon: Icon(
                              isDark ? LucideIcons.sun : LucideIcons.moon,
                              size: 16,
                            ),
                            variant: BtnVariant.outline,
                            onPressed: () => ref
                                .read(themeModeProvider.notifier)
                                .toggleTheme(),
                          ),
                        ],
                      ),
              ),

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

  Widget _buildProfileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        AppInput(placeholder: value, readOnly: true),
      ],
    );
  }

  Widget _card(
    BuildContext context,
    IconData icon,
    String title,
    String? subtitle,
    Widget content,
  ) {
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
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }
}
