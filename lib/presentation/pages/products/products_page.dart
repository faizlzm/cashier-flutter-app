import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/product_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';

import 'widgets/product_tile.dart';
import 'widgets/product_form_dialog.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  @override
  void initState() {
    super.initState();
    // Load products when page opens
    Future.microtask(() {
      ref.read(productManagementProvider.notifier).loadProducts();
    });
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductFormDialog(),
    );
  }

  void _showEditDialog(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFormDialog(product: product),
    );
  }

  void _showDeleteConfirm(Product product) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.alertTriangle, color: cs.error, size: 20),
                const SizedBox(width: 8),
                const Text('Apakah Anda yakin ingin menghapus:'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${product.name}"',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Consumer(
            builder: (context, ref, _) {
              final isSubmitting = ref
                  .watch(productManagementProvider)
                  .isSubmitting;
              return FilledButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final success = await ref
                            .read(productManagementProvider.notifier)
                            .deleteProduct(product.id);
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                style: FilledButton.styleFrom(backgroundColor: cs.error),
                icon: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.trash2, size: 16),
                label: const Text('Hapus'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _toggleProductActive(Product product) {
    ref
        .read(productManagementProvider.notifier)
        .toggleProductActive(product.id, isActive: !product.isActive);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(productManagementProvider);
    final notifier = ref.read(productManagementProvider.notifier);
    final isMobile = context.isMobile;

    // Listen for success messages
    ref.listen<ProductManagementState>(productManagementProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        notifier.clearSuccess();
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!), backgroundColor: cs.error),
        );
        notifier.clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Produk'),
        actions: [
          IconButton(
            icon: state.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  )
                : Icon(LucideIcons.refreshCw, size: 20, color: cs.primary),
            onPressed: state.isLoading ? null : notifier.loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Tambah'),
      ),
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          children: [
            // Search & Filter
            _buildSearchFilter(cs, notifier, state, isMobile),
            const SizedBox(height: 16),

            // Product List
            Expanded(child: _buildProductList(cs, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilter(
    ColorScheme cs,
    ProductManagementNotifier notifier,
    ProductManagementState state,
    bool isMobile,
  ) {
    return Column(
      children: [
        // Search
        AppInput(
          placeholder: 'Cari produk...',
          prefixIcon: Icon(
            LucideIcons.search,
            size: 18,
            color: cs.onSurface.withValues(alpha: 0.4),
          ),
          onChanged: notifier.setSearchQuery,
        ),
        const SizedBox(height: 12),

        // Category Filter - Left aligned
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppButton(
              text: 'Semua',
              variant:
                  (state.selectedCategory == null ||
                      state.selectedCategory == 'ALL')
                  ? BtnVariant.primary
                  : BtnVariant.outline,
              size: BtnSize.sm,
              onPressed: () => notifier.setCategory('ALL'),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'Makanan',
              variant: state.selectedCategory == 'FOOD'
                  ? BtnVariant.primary
                  : BtnVariant.outline,
              size: BtnSize.sm,
              onPressed: () => notifier.setCategory('FOOD'),
            ),
            const SizedBox(width: 8),
            AppButton(
              text: 'Minuman',
              variant: state.selectedCategory == 'DRINK'
                  ? BtnVariant.primary
                  : BtnVariant.outline,
              size: BtnSize.sm,
              onPressed: () => notifier.setCategory('DRINK'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductList(ColorScheme cs, ProductManagementState state) {
    if (state.isLoading && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Memuat produk...',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    if (state.error != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.alertCircle,
              size: 48,
              color: cs.error.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: 'Coba Lagi',
              onPressed: ref
                  .read(productManagementProvider.notifier)
                  .loadProducts,
            ),
          ],
        ),
      );
    }

    final products = state.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.package,
              size: 48,
              color: cs.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              state.searchQuery?.isNotEmpty == true
                  ? 'Tidak ditemukan produk untuk "${state.searchQuery}"'
                  : 'Belum ada produk',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ref.read(productManagementProvider.notifier).loadProducts,
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, index) {
          final product = products[index];
          return ProductTile(
            product: product,
            onEdit: () => _showEditDialog(product),
            onDelete: () => _showDeleteConfirm(product),
            onToggleActive: () => _toggleProductActive(product),
          );
        },
      ),
    );
  }
}
