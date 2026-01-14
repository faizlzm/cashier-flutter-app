import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/offline_database.dart';
import '../core/services/sync_service.dart';
import 'network_status_provider.dart';

/// State for offline sync
class OfflineSyncState {
  final int pendingCount;
  final bool isSyncing;
  final SyncResult? lastSyncResult;
  final String? error;

  const OfflineSyncState({
    this.pendingCount = 0,
    this.isSyncing = false,
    this.lastSyncResult,
    this.error,
  });

  OfflineSyncState copyWith({
    int? pendingCount,
    bool? isSyncing,
    SyncResult? lastSyncResult,
    String? error,
    bool clearError = false,
  }) {
    return OfflineSyncState(
      pendingCount: pendingCount ?? this.pendingCount,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
      error: clearError ? null : (error ?? this.error),
    );
  }

  bool get hasPending => pendingCount > 0;
}

/// Notifier for offline sync state
class OfflineSyncNotifier extends StateNotifier<OfflineSyncState> {
  final Ref _ref;
  final OfflineDatabase _db = OfflineDatabase();
  final SyncService _syncService = SyncService();
  StreamSubscription<NetworkState>? _networkSubscription;

  OfflineSyncNotifier(this._ref) : super(const OfflineSyncState()) {
    _init();
  }

  void _init() {
    // Load initial pending count
    refreshPendingCount();

    // Listen for network changes
    _networkSubscription = _ref
        .read(networkStatusProvider.notifier)
        .stream
        .listen(_onNetworkChange);

    // Also check initial network state
    final networkState = _ref.read(networkStatusProvider);
    if (networkState.isOnline) {
      _tryAutoSync();
    }
  }

  void _onNetworkChange(NetworkState networkState) {
    if (networkState.isOnline && state.hasPending) {
      _tryAutoSync();
    }
  }

  /// Try to sync automatically when coming online
  Future<void> _tryAutoSync() async {
    if (state.isSyncing) return;

    final count = await _db.getPendingTransactionCount();
    if (count > 0) {
      await syncNow();
    }
  }

  /// Refresh the pending transaction count
  Future<void> refreshPendingCount() async {
    final count = await _db.getPendingTransactionCount();
    state = state.copyWith(pendingCount: count);
  }

  /// Manually trigger sync
  Future<SyncResult> syncNow() async {
    if (state.isSyncing) {
      return SyncResult(synced: 0, failed: 0, skipped: true);
    }

    state = state.copyWith(isSyncing: true, clearError: true);

    try {
      final result = await _syncService.syncPendingTransactions();

      // Refresh pending count after sync
      final newCount = await _db.getPendingTransactionCount();

      state = state.copyWith(
        isSyncing: false,
        pendingCount: newCount,
        lastSyncResult: result,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: 'Gagal sync transaksi: $e',
      );
      return SyncResult(synced: 0, failed: 0);
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }
}

/// Global offline sync provider
final offlineSyncProvider =
    StateNotifierProvider<OfflineSyncNotifier, OfflineSyncState>((ref) {
      return OfflineSyncNotifier(ref);
    });

/// Convenience provider for pending count
final pendingTransactionCountProvider = Provider<int>((ref) {
  return ref.watch(offlineSyncProvider).pendingCount;
});

/// Convenience provider for checking if syncing
final isSyncingProvider = Provider<bool>((ref) {
  return ref.watch(offlineSyncProvider).isSyncing;
});
