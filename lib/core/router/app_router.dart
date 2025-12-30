import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/layouts/main_layout.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/pos/pos_page.dart';
import '../../presentation/pages/pos/checkout_page.dart';
import '../../presentation/pages/pos/success_page.dart';
import '../../presentation/pages/transactions/transactions_page.dart';
import '../../presentation/pages/settings/settings_page.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/login',
  routes: [
    // Auth routes (tanpa sidebar)
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordPage()),

    // Main routes (dengan sidebar)
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (_, __, child) => MainLayout(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
        GoRoute(path: '/pos', builder: (_, __) => const PosPage()),
        GoRoute(path: '/pos/checkout', builder: (_, __) => const CheckoutPage()),
        GoRoute(
          path: '/pos/success',
          builder: (_, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SuccessPage(
              received: extra?['received'] ?? 0,
              change: extra?['change'] ?? 0,
              method: extra?['method'] ?? 'CASH',
            );
          },
        ),
        GoRoute(path: '/transactions', builder: (_, __) => const TransactionsPage()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      ],
    ),
  ],
);

