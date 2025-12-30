class TransactionItem {
  final String name;
  final int quantity;
  final int price;
  final String category;

  const TransactionItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
  });
}

class Transaction {
  final String id;
  final List<TransactionItem> items;
  final int total;
  final DateTime date;
  final String status;
  final String paymentMethod;

  const Transaction({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.status,
    required this.paymentMethod,
  });
}

