import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'offline_database.dart';
import 'transaction_service.dart';
import '../../data/models/transaction_model.dart';

/// Service for syncing offline transactions to the server
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final OfflineDatabase _db = OfflineDatabase();
  final TransactionService _transactionService = TransactionService();

  bool _isSyncing = false;
  int _syncedCount = 0;
  int _failedCount = 0;

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Get last sync stats
  int get lastSyncedCount => _syncedCount;
  int get lastFailedCount => _failedCount;

  /// Sync all pending transactions to the server
  /// Returns number of successfully synced transactions
  Future<SyncResult> syncPendingTransactions() async {
    if (_isSyncing) {
      return SyncResult(synced: 0, failed: 0, skipped: true);
    }

    _isSyncing = true;
    _syncedCount = 0;
    _failedCount = 0;

    try {
      final pending = await _db.getPendingTransactions();
      if (pending.isEmpty) {
        return SyncResult(synced: 0, failed: 0);
      }

      debugPrint('[Sync] Starting sync of ${pending.length} transactions');

      for (final tx in pending) {
        // Skip if already failed too many times
        if (tx.retryCount >= 3) {
          debugPrint('[Sync] Skipping ${tx.id} - max retries reached');
          continue;
        }

        try {
          await _syncSingleTransaction(tx);
          _syncedCount++;
        } catch (e) {
          _failedCount++;
          debugPrint('[Sync] Failed to sync ${tx.id}: $e');
        }
      }

      debugPrint(
        '[Sync] Completed: $_syncedCount synced, $_failedCount failed',
      );
      return SyncResult(synced: _syncedCount, failed: _failedCount);
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a single transaction
  Future<void> _syncSingleTransaction(PendingTransaction tx) async {
    // Mark as syncing
    await _db.updateTransactionStatus(tx.id, 'syncing');

    try {
      // Create API request (only includes what API needs)
      final request = CreateTransactionRequest(
        items: tx.data.items
            .map(
              (item) => TransactionItemRequest(
                productId: item.productId,
                quantity: item.quantity,
              ),
            )
            .toList(),
        paymentMethod: tx.data.paymentMethod,
        discount: tx.data.discount,
      );

      // Send to server
      await _transactionService.createTransaction(request);

      // Remove from local queue on success
      await _db.removeTransaction(tx.id);
      debugPrint('[Sync] Successfully synced ${tx.id}');
    } catch (e) {
      // Mark as failed and increment retry count
      await _db.updateTransactionStatus(tx.id, 'failed', incrementRetry: true);
      rethrow;
    }
  }

  /// Retry a specific failed transaction
  Future<bool> retryTransaction(String id) async {
    final pending = await _db.getPendingTransactions();
    final tx = pending.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('Transaction not found'),
    );

    try {
      await _syncSingleTransaction(tx);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all failed transactions
  Future<void> clearFailedTransactions() async {
    await _db.clearSyncedTransactions();
  }
}

/// Result of a sync operation
class SyncResult {
  final int synced;
  final int failed;
  final bool skipped;

  SyncResult({
    required this.synced,
    required this.failed,
    this.skipped = false,
  });

  bool get hasErrors => failed > 0;
  bool get isEmpty => synced == 0 && failed == 0;
}
