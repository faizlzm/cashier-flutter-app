import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/transaction_service.dart';
import '../../data/models/transaction_model.dart';

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      return DashboardNotifier();
    });

class DashboardState {
  final bool isLoading;
  final String? error;
  final List<Transaction> recentTransactions;
  final int todayRevenue;
  final int todayCount;
  final int monthRevenue;
  final int monthCount;
  final int totalProducts;
  final int lowStockProducts;

  const DashboardState({
    this.isLoading = false,
    this.error,
    this.recentTransactions = const [],
    this.todayRevenue = 0,
    this.todayCount = 0,
    this.monthRevenue = 0,
    this.monthCount = 0,
    this.totalProducts = 0,
    this.lowStockProducts = 0,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    List<Transaction>? recentTransactions,
    int? todayRevenue,
    int? todayCount,
    int? monthRevenue,
    int? monthCount,
    int? totalProducts,
    int? lowStockProducts,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      recentTransactions: recentTransactions ?? this.recentTransactions,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      todayCount: todayCount ?? this.todayCount,
      monthRevenue: monthRevenue ?? this.monthRevenue,
      monthCount: monthCount ?? this.monthCount,
      totalProducts: totalProducts ?? this.totalProducts,
      lowStockProducts: lowStockProducts ?? this.lowStockProducts,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final TransactionService _transactionService;

  DashboardNotifier({TransactionService? transactionService})
    : _transactionService = transactionService ?? TransactionService(),
      super(const DashboardState());

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Fetch dashboard summary from /reports/summary (matches PWA)
      final summary = await _transactionService.getDashboardSummary();

      // Also fetch today's transactions for the recent list
      final todayResult = await _transactionService.getTodayTransactions();

      // Sort transactions by date descending for "Latest Transactions" list
      final recent = List<Transaction>.from(todayResult.transactions)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
        isLoading: false,
        todayRevenue: summary.todayRevenue,
        todayCount: summary.todayTransactionCount,
        monthRevenue: summary.monthRevenue,
        monthCount: summary.monthTransactionCount,
        totalProducts: summary.totalProducts,
        lowStockProducts: summary.lowStockProducts,
        recentTransactions: recent.take(5).toList(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data dashboard.',
      );
    }
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }
}
