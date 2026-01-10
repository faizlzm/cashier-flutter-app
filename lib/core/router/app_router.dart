import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../providers/auth_provider.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

/// Auth paths that don't require authentication
const _authPaths = ['/login', '/register', '/forgot-password'];

/// Create the app router with auth redirect support
GoRouter createAppRouter(WidgetRef ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isInitialized = authState.isInitialized;
      final currentPath = state.matchedLocation;
      final isAuthPath = _authPaths.contains(currentPath);

      // Wait for auth to initialize
      if (!isInitialized) {
        return null;
      }

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isAuthPath) {
        return '/login';
      }

      // If authenticated and on auth page, redirect to dashboard
      if (isAuthenticated && isAuthPath) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Auth routes (without sidebar)
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),

      // Main routes (with sidebar)
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (_, __, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardPage(),
          ),
          GoRoute(path: '/pos', builder: (_, __) => const PosPage()),
          GoRoute(
            path: '/pos/checkout',
            builder: (_, __) => const CheckoutPage(),
          ),
          GoRoute(
            path: '/pos/success',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SuccessPage(
                received: extra?['received'] ?? 0,
                change: extra?['change'] ?? 0,
                method: extra?['method'] ?? 'CASH',
                transactionCode: extra?['transactionCode'],
                transactionId: extra?['transactionId'],
              );
            },
          ),
          GoRoute(
            path: '/transactions',
            builder: (_, __) => const TransactionsPage(),
          ),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        ],
      ),
    ],
  );
}

/// Listenable that notifies when auth state changes
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _ref.listen(authProvider, (_, __) {
      notifyListeners();
    });
  }

  final WidgetRef _ref;
}

/// Provider for the router (to be used in app.dart)
final routerProvider = Provider<GoRouter>((ref) {
  throw UnimplementedError('routerProvider must be overridden');
});
