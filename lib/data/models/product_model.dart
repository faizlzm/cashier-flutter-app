/// Product model matching API response
class Product {
  final String id;
  final String name;
  final int price;
  final String category; // "FOOD" or "DRINK"
  final String? imageUrl;
  final int stock;
  final int minStock;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
    this.stock = 0,
    this.minStock = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Product from JSON (API response)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
      stock: json['stock'] as int? ?? 0,
      minStock: json['minStock'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'stock': stock,
      'minStock': minStock,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'stock': stock,
      'minStock': minStock,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create Product from SQLite Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      price: map['price'] as int,
      category: map['category'] as String,
      imageUrl: map['imageUrl'] as String?,
      stock: map['stock'] as int? ?? 0,
      minStock: map['minStock'] as int? ?? 0,
      isActive: (map['isActive'] as int?) == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Check if stock is low
  bool get isLowStock => stock <= minStock && stock > 0;

  /// Check if out of stock
  bool get isOutOfStock => stock <= 0;

  /// Check if can be sold
  bool get canSell => isActive && stock > 0;

  /// Create a copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    int? price,
    String? category,
    String? imageUrl,
    int? stock,
    int? minStock,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: $price, stock: $stock)';
}
