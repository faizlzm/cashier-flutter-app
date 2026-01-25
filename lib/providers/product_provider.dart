import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product_model.dart';
import '../core/services/product_service.dart';
import '../core/services/offline_cache.dart';
import '../core/network/api_exception.dart';

/// State for products list
class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final String? selectedCategory;
  final String? searchQuery;
  final bool isFromCache;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.selectedCategory,
    this.searchQuery,
    this.isFromCache = false,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    String? selectedCategory,
    String? searchQuery,
    bool? isFromCache,
    bool clearError = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  /// Get products filtered by current category
  List<Product> get filteredProducts {
    var filtered = products;

    if (selectedCategory != null && selectedCategory != 'ALL') {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }
}

/// Products provider with API and offline cache support
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductService _productService;
  final OfflineCache _offlineCache;

  ProductsNotifier({ProductService? productService, OfflineCache? offlineCache})
    : _productService = productService ?? ProductService(),
      _offlineCache = offlineCache ?? OfflineCache(),
      super(const ProductsState()) {
    // Load products on initialization
    loadProducts();
  }

  /// Load products from API with offline fallback
  Future<void> loadProducts({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      // Try to get from API first
      final products = await _productService.getActiveProducts();

      // Cache for offline use
      await _offlineCache.cacheProducts(products);

      state = state.copyWith(
        products: products,
        isLoading: false,
        isFromCache: false,
      );
    } on NetworkException {
      // Offline - try cache
      await _loadFromCache();
    } on ApiException catch (e) {
      // API error - try cache if available
      final isCacheValid = await _offlineCache.isProductsCacheValid();
      if (isCacheValid) {
        await _loadFromCache();
        state = state.copyWith(error: '${e.message} (showing cached data)');
      } else {
        state = state.copyWith(isLoading: false, error: e.message);
      }
    } catch (e) {
      // Unknown error - try cache
      await _loadFromCache();
    }
  }

  /// Load from cache
  Future<void> _loadFromCache() async {
    try {
      final cached = await _offlineCache.getCachedProducts(isActive: true);
      if (cached.isNotEmpty) {
        state = state.copyWith(
          products: cached,
          isLoading: false,
          isFromCache: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Tidak ada data tersedia. Periksa koneksi internet.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data produk.',
      );
    }
  }

  /// Refresh products (pull to refresh)
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);

    try {
      final products = await _productService.getActiveProducts();
      await _offlineCache.cacheProducts(products);

      state = state.copyWith(
        products: products,
        isRefreshing: false,
        isFromCache: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Gagal memperbarui data.',
      );
    }
  }

  /// Set category filter
  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Set search query
  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Global products provider
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>(
  (ref) {
    return ProductsNotifier();
  },
);

/// Convenience provider for filtered products
final filteredProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(productsProvider).filteredProducts;
});

/// Convenience provider for loading state
final isProductsLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(productsProvider);
  return state.isLoading || state.isRefreshing;
});

// ============================================================================
// PRODUCT MANAGEMENT (Admin CRUD)
// ============================================================================

/// State for product management (Admin)
class ProductManagementState {
  final List<Product> products;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? successMessage;
  final String? selectedCategory;
  final String? searchQuery;
  final bool? isActiveFilter; // null = All, true = Active, false = Inactive

  const ProductManagementState({
    this.products = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.successMessage,
    this.selectedCategory,
    this.searchQuery,
    this.isActiveFilter,
  });

  ProductManagementState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? successMessage,
    String? selectedCategory,
    String? searchQuery,
    bool? isActiveFilter,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearIsActiveFilter = false,
  }) {
    return ProductManagementState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isActiveFilter: clearIsActiveFilter
          ? null
          : (isActiveFilter ?? this.isActiveFilter),
    );
  }

  /// Get products filtered by current category, search, and status
  List<Product> get filteredProducts {
    var filtered = products;

    if (selectedCategory != null && selectedCategory != 'ALL') {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }

    if (isActiveFilter != null) {
      filtered = filtered.where((p) => p.isActive == isActiveFilter).toList();
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    return filtered..sort((a, b) => a.name.compareTo(b.name));
  }
}

/// Product Management Notifier for Admin CRUD operations
class ProductManagementNotifier extends StateNotifier<ProductManagementState> {
  final ProductService _productService;

  ProductManagementNotifier({ProductService? productService})
    : _productService = productService ?? ProductService(),
      super(const ProductManagementState());

  /// Load all products (including inactive)
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final products = await _productService.getProducts();
      state = state.copyWith(products: products, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat data produk.',
      );
    }
  }

  /// Create a new product
  Future<bool> createProduct({
    required String name,
    required int price,
    required String category,
    int stock = 0,
    int minStock = 5,
    String? imageUrl,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _productService.createProduct(
        name: name,
        price: price,
        category: category,
        stock: stock,
        minStock: minStock,
        imageUrl: imageUrl,
      );
      await loadProducts();
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Produk berhasil ditambahkan',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Gagal menambah produk.',
      );
      return false;
    }
  }

  /// Update an existing product
  Future<bool> updateProduct(
    String id, {
    String? name,
    int? price,
    String? category,
    int? stock,
    int? minStock,
    String? imageUrl,
    bool? isActive,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _productService.updateProduct(
        id,
        name: name,
        price: price,
        category: category,
        stock: stock,
        minStock: minStock,
        imageUrl: imageUrl,
        isActive: isActive,
      );
      await loadProducts();
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Produk berhasil diperbarui',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Gagal memperbarui produk.',
      );
      return false;
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String id) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await _productService.deleteProduct(id);
      await loadProducts();
      state = state.copyWith(
        isSubmitting: false,
        successMessage: 'Produk berhasil dihapus',
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Gagal menghapus produk.',
      );
      return false;
    }
  }

  /// Toggle product active status
  Future<bool> toggleProductActive(String id, {required bool isActive}) async {
    return updateProduct(id, isActive: isActive);
  }

  /// Set category filter
  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Set active status filter
  void setIsActiveFilter(bool? isActive) {
    state = state.copyWith(
      isActiveFilter: isActive,
      clearIsActiveFilter: isActive == null,
    );
  }

  /// Set search query
  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }
}

/// Global product management provider (Admin)
final productManagementProvider =
    StateNotifierProvider<ProductManagementNotifier, ProductManagementState>((
      ref,
    ) {
      return ProductManagementNotifier();
    });

/// Convenience provider for filtered products in management
final filteredManagementProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(productManagementProvider).filteredProducts;
});
