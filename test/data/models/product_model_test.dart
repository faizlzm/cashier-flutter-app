import 'package:flutter_test/flutter_test.dart';
import 'package:cashier_flutter_app/data/models/product_model.dart';

void main() {
  group('Product', () {
    test('should create from JSON', () {
      final json = {
        'id': 'prod-123',
        'name': 'Nasi Goreng',
        'price': 25000,
        'category': 'FOOD',
        'stock': 50,
        'minStock': 10,
        'isActive': true,
        'imageUrl': 'https://example.com/image.jpg',
      };

      final product = Product.fromJson(json);

      expect(product.id, 'prod-123');
      expect(product.name, 'Nasi Goreng');
      expect(product.price, 25000);
      expect(product.category, 'FOOD');
      expect(product.stock, 50);
      expect(product.minStock, 10);
      expect(product.isActive, isTrue);
      expect(product.imageUrl, 'https://example.com/image.jpg');
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'id': 'prod-123',
        'name': 'Test',
        'price': 10000,
        'category': 'DRINK',
      };

      final product = Product.fromJson(json);

      expect(product.stock, 0);
      expect(product.minStock, 0);
      expect(product.isActive, isTrue);
      expect(product.imageUrl, isNull);
    });

    test('toJson should include all fields', () {
      final product = Product(
        id: 'prod-123',
        name: 'Test',
        price: 10000,
        category: 'FOOD',
        stock: 20,
        imageUrl: 'https://example.com/img.jpg',
      );

      final json = product.toJson();

      expect(json['id'], 'prod-123');
      expect(json['name'], 'Test');
      expect(json['price'], 10000);
      expect(json['imageUrl'], 'https://example.com/img.jpg');
    });

    test('toMap should convert isActive to int for SQLite', () {
      final product = Product(
        id: '1',
        name: 'Test',
        price: 10000,
        category: 'FOOD',
        isActive: true,
      );

      final map = product.toMap();

      expect(map['isActive'], 1);
    });

    test('fromMap should convert int back to bool', () {
      final map = {
        'id': '1',
        'name': 'Test',
        'price': 10000,
        'category': 'FOOD',
        'isActive': 0,
        'stock': 5,
        'minStock': 2,
      };

      final product = Product.fromMap(map);

      expect(product.isActive, isFalse);
    });

    test('isLowStock should be true when stock <= minStock and > 0', () {
      final lowStock = Product(
        id: '1',
        name: 'Test',
        price: 10000,
        category: 'FOOD',
        stock: 5,
        minStock: 10,
      );

      expect(lowStock.isLowStock, isTrue);
      expect(lowStock.isOutOfStock, isFalse);
    });

    test('isOutOfStock should be true when stock is 0', () {
      final outOfStock = Product(
        id: '1',
        name: 'Test',
        price: 10000,
        category: 'FOOD',
        stock: 0,
      );

      expect(outOfStock.isOutOfStock, isTrue);
      expect(outOfStock.canSell, isFalse);
    });

    test('canSell should be true when isActive and has stock', () {
      final canSell = Product(
        id: '1',
        name: 'Test',
        price: 10000,
        category: 'FOOD',
        stock: 10,
        isActive: true,
      );

      expect(canSell.canSell, isTrue);
    });

    test('canSell should be false when isActive is false', () {
      final inactive = Product(
        id: '1',
        name: 'Test',
        price: 10000,
        category: 'FOOD',
        stock: 10,
        isActive: false,
      );

      expect(inactive.canSell, isFalse);
    });

    test('copyWith should create new instance with updated values', () {
      final original = Product(
        id: '1',
        name: 'Original',
        price: 10000,
        category: 'FOOD',
        stock: 10,
      );

      final updated = original.copyWith(name: 'Updated', price: 15000);

      expect(updated.name, 'Updated');
      expect(updated.price, 15000);
      expect(updated.id, '1'); // unchanged
      expect(original.name, 'Original'); // original unchanged
    });

    test('equality should be based on id', () {
      final product1 = Product(
        id: '1',
        name: 'Product 1',
        price: 10000,
        category: 'FOOD',
      );

      final product2 = Product(
        id: '1',
        name: 'Different Name',
        price: 20000,
        category: 'DRINK',
      );

      expect(product1, equals(product2)); // Same id
    });
  });
}
