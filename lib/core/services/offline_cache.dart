import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/product_model.dart';
import '../config/app_config.dart';

/// Offline cache for products using SQLite
/// Note: SQLite (sqflite) is not supported on web platform
class OfflineCache {
  static final OfflineCache _instance = OfflineCache._internal();
  factory OfflineCache() => _instance;
  OfflineCache._internal();

  Database? _database;

  /// Check if caching is available (not on web)
  bool get isAvailable => !kIsWeb;

  Future<Database> get database async {
    if (!isAvailable) {
      throw UnsupportedError('SQLite is not available on web platform');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConfig.databaseName);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price INTEGER NOT NULL,
        category TEXT NOT NULL,
        imageUrl TEXT,
        stock INTEGER DEFAULT 0,
        minStock INTEGER DEFAULT 0,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    // Metadata table (for cache timestamps)
    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_products_category ON products(category)',
    );
    await db.execute(
      'CREATE INDEX idx_products_isActive ON products(isActive)',
    );
  }

  // ==================== Products ====================

  /// Cache products from API (silently fails on web)
  Future<void> cacheProducts(List<Product> products) async {
    if (!isAvailable) return; // Skip caching on web

    try {
      final db = await database;

      await db.transaction((txn) async {
        // Clear existing products
        await txn.delete('products');

        // Insert new products
        for (final product in products) {
          await txn.insert(
            'products',
            product.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        // Update cache timestamp
        await txn.insert('metadata', {
          'key': 'products_cached_at',
          'value': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      });
    } catch (e) {
      // Silently fail - caching is best-effort
      debugPrint('[OfflineCache] Failed to cache products: $e');
    }
  }

  /// Get cached products (returns empty list on web or error)
  Future<List<Product>> getCachedProducts({
    String? category,
    String? search,
    bool? isActive,
  }) async {
    if (!isAvailable) return []; // No cache on web

    try {
      final db = await database;

      String whereClause = '';
      List<dynamic> whereArgs = [];

      if (isActive != null) {
        whereClause = 'isActive = ?';
        whereArgs.add(isActive ? 1 : 0);
      }

      if (category != null && category != 'ALL') {
        whereClause += whereClause.isNotEmpty ? ' AND ' : '';
        whereClause += 'category = ?';
        whereArgs.add(category);
      }

      if (search != null && search.isNotEmpty) {
        whereClause += whereClause.isNotEmpty ? ' AND ' : '';
        whereClause += 'name LIKE ?';
        whereArgs.add('%$search%');
      }

      final maps = await db.query(
        'products',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'name ASC',
      );

      return maps.map((map) => Product.fromMap(map)).toList();
    } catch (e) {
      debugPrint('[OfflineCache] Failed to get cached products: $e');
      return [];
    }
  }

  /// Check if products cache is valid (not expired)
  Future<bool> isProductsCacheValid() async {
    if (!isAvailable) return false; // No cache on web

    try {
      final db = await database;

      final result = await db.query(
        'metadata',
        where: 'key = ?',
        whereArgs: ['products_cached_at'],
      );

      if (result.isEmpty) return false;

      final cachedAt = DateTime.parse(result.first['value'] as String);
      final expiry = cachedAt.add(AppConfig.productsCacheExpiry);

      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }

  /// Get cache timestamp
  Future<DateTime?> getProductsCachedAt() async {
    if (!isAvailable) return null; // No cache on web

    try {
      final db = await database;

      final result = await db.query(
        'metadata',
        where: 'key = ?',
        whereArgs: ['products_cached_at'],
      );

      if (result.isEmpty) return null;

      return DateTime.parse(result.first['value'] as String);
    } catch (e) {
      return null;
    }
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    if (!isAvailable) return; // No cache on web

    try {
      final db = await database;
      await db.delete('products');
      await db.delete('metadata');
    } catch (e) {
      debugPrint('[OfflineCache] Failed to clear cache: $e');
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (!isAvailable) return; // No cache on web

    try {
      final db = await database;
      await db.close();
      _database = null;
    } catch (e) {
      debugPrint('[OfflineCache] Failed to close database: $e');
    }
  }
}

/// Debug print helper
void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
