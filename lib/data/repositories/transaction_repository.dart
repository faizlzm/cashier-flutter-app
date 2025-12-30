import '../models/transaction_model.dart';

class TransactionRepository {
  static List<Transaction> transactions = [
    Transaction(
      id: 'TRX-001',
      items: const [
        TransactionItem(name: 'Nasi Goreng Special', quantity: 2, price: 25000, category: 'FOOD'),
        TransactionItem(name: 'Es Teh Manis', quantity: 2, price: 5000, category: 'DRINK'),
      ],
      total: 60000,
      date: DateTime.now().subtract(const Duration(minutes: 15)),
      status: 'PAID',
      paymentMethod: 'CASH',
    ),
    Transaction(
      id: 'TRX-002',
      items: const [
        TransactionItem(name: 'Mie Ayam Bakso', quantity: 1, price: 20000, category: 'FOOD'),
        TransactionItem(name: 'Kopi Susu', quantity: 1, price: 12000, category: 'DRINK'),
      ],
      total: 32000,
      date: DateTime.now().subtract(const Duration(hours: 1)),
      status: 'PAID',
      paymentMethod: 'QRIS',
    ),
    Transaction(
      id: 'TRX-003',
      items: const [
        TransactionItem(name: 'Soto Ayam', quantity: 1, price: 18000, category: 'FOOD'),
      ],
      total: 18000,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'PAID',
      paymentMethod: 'CASH',
    ),
    Transaction(
      id: 'TRX-004',
      items: const [
        TransactionItem(name: 'Nasi Padang', quantity: 2, price: 23000, category: 'FOOD'),
        TransactionItem(name: 'Es Jeruk', quantity: 2, price: 7000, category: 'DRINK'),
      ],
      total: 60000,
      date: DateTime.now().subtract(const Duration(hours: 4)),
      status: 'PAID',
      paymentMethod: 'CASH',
    ),
    Transaction(
      id: 'TRX-005',
      items: const [
        TransactionItem(name: 'Ayam Geprek', quantity: 1, price: 15000, category: 'FOOD'),
      ],
      total: 15000,
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: 'PAID',
      paymentMethod: 'CASH',
    ),
  ];

  List<Transaction> getAll() => transactions;
}

