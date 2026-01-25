/// Kasir Pro - Main Application Widget
///
/// Root widget for the Kasir Pro application.
/// Handles theme configuration, auth state, and routing.
///
/// Features:
/// - Light/Dark theme switching
/// - Auth-aware routing with GoRouter
/// - Animated splash screen during initialization
///
/// @author Kasir Pro Team
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/business_settings_provider.dart';

class CashierApp extends ConsumerWidget {
  const CashierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authProvider);

    // Show loading screen while auth is initializing
    if (!authState.isInitialized) {
      return MaterialApp(
        title: 'Kasir Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const _SplashScreen(),
      );
    }

    // Create router with auth awareness
    final router = createAppRouter(ref);

    // Sync tax rate from settings
    ref.listen(businessSettingsProvider, (previous, next) {
      next.whenData((settings) {
        if (settings != null) {
          ref.read(cartProvider.notifier).setTaxRate(settings.taxRate);
        }
      });
    });

    return MaterialApp.router(
      title: 'Kasir Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

/// Splash screen shown while checking authentication
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

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
            colors: [
              cs.primary.withValues(alpha: 0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.point_of_sale_rounded,
                  size: 40,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Kasir Pro',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
