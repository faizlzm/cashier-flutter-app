import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../core/services/transaction_service.dart';
import '../core/services/offline_database.dart';
import '../core/network/api_exception.dart';
import 'network_status_provider.dart';
import 'offline_sync_provider.dart';

/// State for transactions list
class TransactionsState {
  final List<Transaction> transactions;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? filterDate;

  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.filterDate,
  });

  TransactionsState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? filterDate,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      filterDate: clearFilter ? null : (filterDate ?? this.filterDate),
    );
  }

  /// Get transactions filtered by date (local filter)
  List<Transaction> get filteredTransactions {
    if (filterDate == null) return transactions;

    return transactions.where((t) {
      return t.createdAt.year == filterDate!.year &&
          t.createdAt.month == filterDate!.month &&
          t.createdAt.day == filterDate!.day;
    }).toList();
  }
}

/// Transactions provider for listing history
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final TransactionService _transactionService;

  TransactionsNotifier({TransactionService? transactionService})
    : _transactionService = transactionService ?? TransactionService(),
      super(const TransactionsState());

  /// Load transactions from API
  Future<void> loadTransactions({DateTime? date}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      List<Transaction> transactions;

      if (date != null) {
        // If filtering by date, we might not need limit if API returns all
        // But better safe with pagination, maybe larger limit
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        transactions = await _transactionService.getTransactions(
          startDate: startOfDay,
          endDate: endOfDay,
          limit: 100, // Fetch more when filtering by date
        );
      } else {
        // Fetch valid list size like PWA (limit: 50)
        transactions = await _transactionService.getTransactions(limit: 50);
      }

      // Sort by date descending
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
        transactions: transactions,
        isLoading: false,
        filterDate: date,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat riwayat transaksi.',
      );
    }
  }

  /// Refresh transactions
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);

    try {
      final transactions = await _transactionService.getTransactions(limit: 50);
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
        transactions: transactions,
        isRefreshing: false,
        clearError: true,
        clearFilter: true,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Gagal memperbarui data.',
      );
    }
  }

  /// Set date filter
  void setDateFilter(DateTime? date) {
    state = state.copyWith(filterDate: date, clearFilter: date == null);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// State for creating a transaction (checkout)
class CheckoutState {
  final bool isSubmitting;
  final Transaction? completedTransaction;
  final String? error;
  final bool isOfflineTransaction;

  const CheckoutState({
    this.isSubmitting = false,
    this.completedTransaction,
    this.error,
    this.isOfflineTransaction = false,
  });

  CheckoutState copyWith({
    bool? isSubmitting,
    Transaction? completedTransaction,
    String? error,
    bool? isOfflineTransaction,
    bool clearError = false,
    bool clearTransaction = false,
  }) {
    return CheckoutState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      completedTransaction: clearTransaction
          ? null
          : (completedTransaction ?? this.completedTransaction),
      error: clearError ? null : (error ?? this.error),
      isOfflineTransaction: isOfflineTransaction ?? this.isOfflineTransaction,
    );
  }
}

/// Checkout provider for creating transactions (with offline support)
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final TransactionService _transactionService;
  final Ref _ref;

  CheckoutNotifier(this._ref, {TransactionService? transactionService})
    : _transactionService = transactionService ?? TransactionService(),
      super(const CheckoutState());

  /// Submit transaction to API (or queue offline)
  Future<Transaction?> submitTransaction({
    required List<TransactionItemRequest> items,
    required String paymentMethod,
    required int subtotal,
    required int tax,
    required int total,
    int? discount,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    // Check network status
    final isOnline = _ref.read(isOnlineProvider);

    if (isOnline) {
      // Online - send to API
      return _submitOnline(items, paymentMethod, discount);
    } else {
      // Offline - queue locally
      return _submitOffline(
        items: items,
        paymentMethod: paymentMethod,
        subtotal: subtotal,
        tax: tax,
        total: total,
        discount: discount,
      );
    }
  }

  /// Submit to API when online
  Future<Transaction?> _submitOnline(
    List<TransactionItemRequest> items,
    String paymentMethod,
    int? discount,
  ) async {
    try {
      final request = CreateTransactionRequest(
        items: items,
        paymentMethod: paymentMethod,
        discount: discount,
      );

      final transaction = await _transactionService.createTransaction(request);

      state = state.copyWith(
        isSubmitting: false,
        completedTransaction: transaction,
        isOfflineTransaction: false,
      );

      return transaction;
    } on ValidationException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.errors.isNotEmpty ? e.errors.first.message : e.message,
      );
      return null;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Gagal menyimpan transaksi. Silakan coba lagi.',
      );
      return null;
    }
  }

  /// Queue transaction locally when offline
  Future<Transaction?> _submitOffline({
    required List<TransactionItemRequest> items,
    required String paymentMethod,
    required int subtotal,
    required int tax,
    required int total,
    int? discount,
  }) async {
    try {
      final db = OfflineDatabase();

      final request = CreateTransactionRequest(
        items: items,
        paymentMethod: paymentMethod,
        discount: discount,
        subtotal: subtotal,
        tax: tax,
        total: total,
      );

      final pending = await db.queueTransaction(request);
      final localTransaction = pending.toLocalTransaction();

      // Refresh pending count in sync provider
      _ref.read(offlineSyncProvider.notifier).refreshPendingCount();

      state = state.copyWith(
        isSubmitting: false,
        completedTransaction: localTransaction,
        isOfflineTransaction: true,
      );

      return localTransaction;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Gagal menyimpan transaksi offline: $e',
      );
      return null;
    }
  }

  /// Reset checkout state
  void reset() {
    state = const CheckoutState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Global transactions provider (for history)
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
      return TransactionsNotifier();
    });

/// Global checkout provider (for creating transactions)
final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) {
    return CheckoutNotifier(ref);
  },
);
