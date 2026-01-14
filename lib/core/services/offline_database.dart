import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../../data/models/product_model.dart';
import '../../data/models/transaction_model.dart';

/// Offline database for caching products and queuing transactions
class OfflineDatabase {
  static final OfflineDatabase _instance = OfflineDatabase._internal();
  factory OfflineDatabase() => _instance;
  OfflineDatabase._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cashier_offline.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Pending transactions table
    await db.execute('''
      CREATE TABLE pending_transactions (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        retry_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Cached products table
    await db.execute('''
      CREATE TABLE cached_products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT,
        stock INTEGER NOT NULL DEFAULT 0,
        min_stock INTEGER NOT NULL DEFAULT 5,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Metadata table
    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_products_category ON cached_products(category)',
    );
    await db.execute(
      'CREATE INDEX idx_pending_status ON pending_transactions(status)',
    );
  }

  // ==================== PENDING TRANSACTIONS ====================

  /// Queue a transaction for later sync
  Future<PendingTransaction> queueTransaction(
    CreateTransactionRequest request,
  ) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().toIso8601String();

    final pending = PendingTransaction(
      id: id,
      data: request,
      createdAt: now,
      status: 'pending',
      retryCount: 0,
    );

    await db.insert('pending_transactions', pending.toMap());
    return pending;
  }

  /// Get all pending transactions
  Future<List<PendingTransaction>> getPendingTransactions() async {
    final db = await database;
    final results = await db.query(
      'pending_transactions',
      orderBy: 'created_at ASC',
    );

    return results.map((map) => PendingTransaction.fromMap(map)).toList();
  }

  /// Get pending transactions count
  Future<int> getPendingTransactionCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM pending_transactions WHERE status = ?',
      ['pending'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Update transaction status
  Future<void> updateTransactionStatus(
    String id,
    String status, {
    bool incrementRetry = false,
  }) async {
    final db = await database;

    if (incrementRetry) {
      await db.rawUpdate(
        'UPDATE pending_transactions SET status = ?, retry_count = retry_count + 1 WHERE id = ?',
        [status, id],
      );
    } else {
      await db.update(
        'pending_transactions',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// Remove a synced transaction
  Future<void> removeTransaction(String id) async {
    final db = await database;
    await db.delete('pending_transactions', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all synced/failed transactions
  Future<void> clearSyncedTransactions() async {
    final db = await database;
    await db.delete(
      'pending_transactions',
      where: 'status != ?',
      whereArgs: ['pending'],
    );
  }

  // ==================== CACHED PRODUCTS ====================

  /// Cache products for offline use
  Future<void> cacheProducts(List<Product> products) async {
    final db = await database;

    await db.transaction((txn) async {
      // Clear existing cache
      await txn.delete('cached_products');

      // Insert new products
      for (final product in products) {
        await txn.insert('cached_products', {
          'id': product.id,
          'name': product.name,
          'price': product.price,
          'category': product.category,
          'image_url': product.imageUrl,
          'stock': product.stock,
          'min_stock': product.minStock,
          'is_active': product.isActive ? 1 : 0,
          'created_at': product.createdAt?.toIso8601String(),
          'updated_at': product.updatedAt?.toIso8601String(),
        });
      }
    });

    // Update cache timestamp
    await setMetadata(
      'products_cached_at',
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Get cached products with optional filtering
  Future<List<Product>> getCachedProducts({
    String? category,
    String? search,
    bool? isActive,
  }) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (category != null) {
      whereClause = 'category = ?';
      whereArgs.add(category);
    }

    if (isActive != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'is_active = ?';
      whereArgs.add(isActive ? 1 : 0);
    }

    final results = await db.query(
      'cached_products',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );

    var products = results
        .map(
          (map) => Product(
            id: map['id'] as String,
            name: map['name'] as String,
            price: map['price'] as int,
            category: map['category'] as String,
            imageUrl: map['image_url'] as String?,
            stock: map['stock'] as int,
            minStock: map['min_stock'] as int,
            isActive: (map['is_active'] as int) == 1,
            createdAt: map['created_at'] != null
                ? DateTime.tryParse(map['created_at'] as String)
                : null,
            updatedAt: map['updated_at'] != null
                ? DateTime.tryParse(map['updated_at'] as String)
                : null,
          ),
        )
        .toList();

    // Apply search filter in memory
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      products = products
          .where((p) => p.name.toLowerCase().contains(searchLower))
          .toList();
    }

    return products;
  }

  /// Check if products cache is valid
  Future<bool> isProductsCacheValid({
    Duration maxAge = const Duration(hours: 24),
  }) async {
    final cachedAtStr = await getMetadata('products_cached_at');
    if (cachedAtStr == null) return false;

    final cachedAt = int.tryParse(cachedAtStr);
    if (cachedAt == null) return false;

    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    return age < maxAge.inMilliseconds;
  }

  // ==================== METADATA ====================

  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    await db.insert('metadata', {
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getMetadata(String key) async {
    final db = await database;
    final results = await db.query(
      'metadata',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }

  // ==================== UTILITIES ====================

  /// Clear all offline data (for logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('pending_transactions');
    await db.delete('cached_products');
    await db.delete('metadata');
  }

  /// Get offline storage stats
  Future<OfflineStats> getStats() async {
    final db = await database;

    final productCount =
        (await db.rawQuery(
              'SELECT COUNT(*) as count FROM cached_products',
            )).first['count']
            as int? ??
        0;

    final pendingCount =
        (await db.rawQuery(
              'SELECT COUNT(*) as count FROM pending_transactions WHERE status = ?',
              ['pending'],
            )).first['count']
            as int? ??
        0;

    final cachedAtStr = await getMetadata('products_cached_at');
    int? cacheAge;
    if (cachedAtStr != null) {
      final cachedAt = int.tryParse(cachedAtStr);
      if (cachedAt != null) {
        cacheAge = DateTime.now().millisecondsSinceEpoch - cachedAt;
      }
    }

    return OfflineStats(
      productCount: productCount,
      pendingTransactionCount: pendingCount,
      cacheAgeMs: cacheAge,
    );
  }
}

/// Pending transaction model
class PendingTransaction {
  final String id;
  final CreateTransactionRequest data;
  final String createdAt;
  final String status;
  final int retryCount;

  PendingTransaction({
    required this.id,
    required this.data,
    required this.createdAt,
    required this.status,
    required this.retryCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data.toJsonString(),
      'created_at': createdAt,
      'status': status,
      'retry_count': retryCount,
    };
  }

  factory PendingTransaction.fromMap(Map<String, dynamic> map) {
    return PendingTransaction(
      id: map['id'] as String,
      data: CreateTransactionRequest.fromJsonString(map['data'] as String),
      createdAt: map['created_at'] as String,
      status: map['status'] as String,
      retryCount: map['retry_count'] as int,
    );
  }

  /// Generate a local transaction code
  String get localTransactionCode {
    final date = DateTime.now();
    final dateStr =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    final shortId = id.length > 4 ? id.substring(id.length - 4) : id;
    return 'TRX-$dateStr-LOCAL-$shortId';
  }

  /// Convert to a local Transaction object for UI
  Transaction toLocalTransaction() {
    return Transaction(
      id: id,
      transactionCode: localTransactionCode,
      userId: 'local',
      subtotal: data.subtotal ?? 0,
      tax: data.tax ?? 0,
      discount: data.discount ?? 0,
      total: data.total ?? 0,
      status: 'PENDING',
      paymentMethod: data.paymentMethod,
      createdAt: DateTime.parse(createdAt),
      items: data.items
          .asMap()
          .entries
          .map(
            (entry) => TransactionItem(
              id: 'local-item-${entry.key}',
              productId: entry.value.productId,
              productName: entry.value.productName,
              quantity: entry.value.quantity,
              price: entry.value.price,
              subtotal: entry.value.price * entry.value.quantity,
              category: entry.value.category,
            ),
          )
          .toList(),
    );
  }
}

/// Offline storage statistics
class OfflineStats {
  final int productCount;
  final int pendingTransactionCount;
  final int? cacheAgeMs;

  OfflineStats({
    required this.productCount,
    required this.pendingTransactionCount,
    this.cacheAgeMs,
  });
}
