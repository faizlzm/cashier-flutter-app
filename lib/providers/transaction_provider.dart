import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../core/services/transaction_service.dart';
import '../core/services/offline_database.dart';
import '../core/network/api_exception.dart';
import 'network_status_provider.dart';
import 'offline_sync_provider.dart';

/// State for transactions list
/// State for transactions list
class TransactionsState {
  final List<Transaction> transactions;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  // Filters
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final String? paymentMethod;

  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.startDate,
    this.endDate,
    this.status,
    this.paymentMethod,
  });

  TransactionsState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? paymentMethod,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      startDate: clearFilters ? null : (startDate ?? this.startDate),
      endDate: clearFilters ? null : (endDate ?? this.endDate),
      status: clearFilters ? null : (status ?? this.status),
      paymentMethod: clearFilters
          ? null
          : (paymentMethod ?? this.paymentMethod),
    );
  }
}

/// Transactions provider for listing history
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  final TransactionService _transactionService;

  TransactionsNotifier({TransactionService? transactionService})
    : _transactionService = transactionService ?? TransactionService(),
      super(const TransactionsState());

  /// Load transactions using CURRENT filters in state
  Future<void> loadTransactions() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final transactions = await _transactionService.getTransactions(
        startDate: state.startDate,
        endDate: state.endDate,
        status: state.status,
        paymentMethod: state.paymentMethod,
        limit: 50,
      );

      // Sort by date descending
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(isLoading: false, transactions: transactions);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat riwayat transaksi.',
      );
    }
  }

  /// Apply specific filters and reload
  /// Passing null means "no filter" (reset that specific filter) to avoid ambiguity,
  /// we assume if you call this, you are providing the desired state for these fields.
  Future<void> setFilters({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? paymentMethod,
  }) async {
    // We construct a new state with updated filters to ensure nulls are respected
    // (copyWith typically ignores nulls, so we manually construct or use special flags)
    // Here we preserve transactions/loading/error but replace filters.

    state = TransactionsState(
      transactions: state.transactions,
      isLoading: true, // Set loading immediately
      isRefreshing: state.isRefreshing,
      error: null, // Clear error on new filter
      startDate: startDate,
      endDate: endDate,
      status: status,
      paymentMethod: paymentMethod,
    );

    await loadTransactions();
  }

  /// Refresh transactions using current filters (for Pull to Refresh)
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await loadTransactions();
    state = state.copyWith(isRefreshing: false);
  }

  /// Reset all filters and reload
  Future<void> resetFilters() async {
    state = TransactionsState(
      transactions: state.transactions,
      isLoading: true,
      error: null,
      // All filters null by default in constructor
    );
    await loadTransactions();
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
