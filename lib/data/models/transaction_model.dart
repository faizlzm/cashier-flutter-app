import 'product_model.dart';

/// Transaction item matching API response
class TransactionItem {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final int price;
  final int subtotal;
  final String? category;

  const TransactionItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.category,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    // Handle nested product object if present
    final product = json['product'] as Map<String, dynamic>?;

    final quantity = json['quantity'] as int;
    final price = json['price'] as int;
    // Calculate subtotal if not provided
    final subtotal = json['subtotal'] as int? ?? (price * quantity);

    return TransactionItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName:
          product?['name'] as String? ?? json['productName'] as String? ?? '',
      quantity: quantity,
      price: price,
      subtotal: subtotal,
      // Category can be from nested product or directly on the item
      category: json['category'] as String? ?? product?['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity, 'price': price};
  }

  /// Create from cart item (for new transaction)
  factory TransactionItem.fromCartItem({
    required Product product,
    required int quantity,
  }) {
    return TransactionItem(
      id: '', // Will be assigned by API
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      price: product.price,
      subtotal: product.price * quantity,
      category: product.category,
    );
  }
}

/// Transaction matching API response
class Transaction {
  final String id;
  final String transactionCode;
  final String userId;
  final List<TransactionItem> items;
  final int subtotal;
  final int tax;
  final int discount;
  final int total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Transaction({
    required this.id,
    required this.transactionCode,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];

    return Transaction(
      id: json['id'] as String,
      transactionCode: json['transactionCode'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      items: itemsJson
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: json['subtotal'] as int? ?? 0,
      tax: json['tax'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      total: json['total'] as int,
      paymentMethod: json['paymentMethod'] as String? ?? 'CASH',
      status: json['status'] as String? ?? 'COMPLETED',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionCode': transactionCode,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Get date for display (alias for createdAt)
  DateTime get date => createdAt;

  /// Total item count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Transaction(code: $transactionCode, total: $total)';
}

/// Request payload for creating a new transaction
class CreateTransactionRequest {
  final List<TransactionItemRequest> items;
  final String paymentMethod;
  final int? discount;

  const CreateTransactionRequest({
    required this.items,
    required this.paymentMethod,
    this.discount,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'paymentMethod': paymentMethod,
      if (discount != null && discount! > 0) 'discount': discount,
    };
  }
}

/// Item in transaction request
class TransactionItemRequest {
  final String productId;
  final int quantity;

  const TransactionItemRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'quantity': quantity};
  }
}

/// Result from getTodayTransactions API
class TodayTransactionsResult {
  final List<Transaction> transactions;
  final int count;
  final int total;

  const TodayTransactionsResult({
    required this.transactions,
    required this.count,
    required this.total,
  });

  factory TodayTransactionsResult.fromJson(Map<String, dynamic> json) {
    // API returns: { transactions: [...], summary: { count: 1, total: 1000 } }
    final transactionsJson = json['transactions'] as List? ?? [];
    final summary = json['summary'] as Map<String, dynamic>?;

    return TodayTransactionsResult(
      transactions: transactionsJson
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: summary?['count'] as int? ?? 0,
      total: summary?['total'] as int? ?? 0,
    );
  }
}

/// Dashboard summary matching /reports/summary API response
class DashboardSummary {
  final int todayRevenue;
  final int todayTransactionCount;
  final int monthRevenue;
  final int monthTransactionCount;
  final int totalProducts;
  final int lowStockProducts;

  const DashboardSummary({
    required this.todayRevenue,
    required this.todayTransactionCount,
    required this.monthRevenue,
    required this.monthTransactionCount,
    required this.totalProducts,
    required this.lowStockProducts,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final today = json['today'] as Map<String, dynamic>? ?? {};
    final month = json['month'] as Map<String, dynamic>? ?? {};
    final products = json['products'] as Map<String, dynamic>? ?? {};

    return DashboardSummary(
      todayRevenue: today['revenue'] as int? ?? 0,
      todayTransactionCount: today['transactionCount'] as int? ?? 0,
      monthRevenue: month['revenue'] as int? ?? 0,
      monthTransactionCount: month['transactionCount'] as int? ?? 0,
      totalProducts: products['total'] as int? ?? 0,
      lowStockProducts: products['lowStock'] as int? ?? 0,
    );
  }
}
