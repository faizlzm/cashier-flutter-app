import 'package:dio/dio.dart';
import '../../data/models/product_model.dart';
import '../network/api_client.dart';

/// Product service for API interactions
class ProductService {
  final ApiClient _apiClient;

  ProductService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Get all products with optional filters
  Future<List<Product>> getProducts({
    String? category,
    String? search,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (category != null && category != 'ALL') {
        queryParams['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (isActive != null) {
        queryParams['isActive'] = isActive;
      }

      final response = await _apiClient.get(
        '/products',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data['data'] as List;
      return data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Get active products only (for POS)
  Future<List<Product>> getActiveProducts({
    String? category,
    String? search,
  }) async {
    return getProducts(category: category, search: search, isActive: true);
  }

  /// Get product by ID
  Future<Product> getProductById(String id) async {
    try {
      final response = await _apiClient.get('/products/$id');
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Get products with low stock
  Future<List<Product>> getLowStockProducts() async {
    try {
      final response = await _apiClient.get('/inventory/low-stock');
      final data = response.data['data'] as List;
      return data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Create a new product
  Future<Product> createProduct({
    required String name,
    required int price,
    required String category,
    int stock = 0,
    int minStock = 5,
    String? imageUrl,
  }) async {
    try {
      final response = await _apiClient.post(
        '/products',
        data: {
          'name': name,
          'price': price,
          'category': category,
          'stock': stock,
          'minStock': minStock,
          if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
        },
      );
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Update an existing product
  Future<Product> updateProduct(
    String id, {
    String? name,
    int? price,
    String? category,
    int? stock,
    int? minStock,
    String? imageUrl,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (price != null) data['price'] = price;
      if (category != null) data['category'] = category;
      if (stock != null) data['stock'] = stock;
      if (minStock != null) data['minStock'] = minStock;
      if (imageUrl != null) data['imageUrl'] = imageUrl;
      if (isActive != null) data['isActive'] = isActive;

      final response = await _apiClient.put('/products/$id', data: data);
      return Product.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete('/products/$id');
    } on DioException catch (e) {
      throw e.apiException;
    }
  }

  /// Toggle product active status
  Future<Product> toggleProductActive(
    String id, {
    required bool isActive,
  }) async {
    return updateProduct(id, isActive: isActive);
  }
}
