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
