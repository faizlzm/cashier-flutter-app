import '../models/transaction_model.dart';

/// Transaction repository - deprecated, use TransactionsProvider instead
/// This is kept for backward compatibility during transition
class TransactionRepository {
  // For backward compatibility, returns empty list
  // Real data should come from TransactionsProvider
  static List<Transaction> transactions = [];

  List<Transaction> getAll() => transactions;
}
