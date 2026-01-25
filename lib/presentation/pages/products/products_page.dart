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

  void _showFilterBottomSheet() {
    final notifier = ref.read(productManagementProvider.notifier);
    final state = ref.read(productManagementProvider);

    // Temporary state variables
    String? tempCategory = state.selectedCategory;
    bool? tempIsActive = state.isActiveFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Produk',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempCategory = null; // 'ALL' effectively
                            tempIsActive = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Category Section
                  Text(
                    'Kategori',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        isSelected:
                            tempCategory == null || tempCategory == 'ALL',
                        onSelected: (_) => setState(() => tempCategory = 'ALL'),
                      ),
                      _buildFilterChip(
                        label: 'Makanan',
                        isSelected: tempCategory == 'FOOD',
                        onSelected: (_) =>
                            setState(() => tempCategory = 'FOOD'),
                      ),
                      _buildFilterChip(
                        label: 'Minuman',
                        isSelected: tempCategory == 'DRINK',
                        onSelected: (_) =>
                            setState(() => tempCategory = 'DRINK'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status Section
                  Text(
                    'Status',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        isSelected: tempIsActive == null,
                        onSelected: (_) => setState(() => tempIsActive = null),
                      ),
                      _buildFilterChip(
                        label: 'Aktif',
                        isSelected: tempIsActive == true,
                        onSelected: (_) => setState(() => tempIsActive = true),
                      ),
                      _buildFilterChip(
                        label: 'Nonaktif',
                        isSelected: tempIsActive == false,
                        onSelected: (_) => setState(() => tempIsActive = false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        notifier.setCategory(tempCategory);
                        notifier.setIsActiveFilter(tempIsActive);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    final theme = Theme.of(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      selectedColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildSearchFilter(
    ColorScheme cs,
    ProductManagementNotifier notifier,
    ProductManagementState state,
    bool isMobile,
  ) {
    // Check active filters
    final bool isCategoryActive =
        state.selectedCategory != null && state.selectedCategory != 'ALL';
    final bool isStatusActive = state.isActiveFilter != null;
    final bool isFilterActive = isCategoryActive || isStatusActive;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Filter Button Row
        Row(
          children: [
            Expanded(
              child: AppInput(
                placeholder: 'Cari produk...',
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 18,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
                onChanged: notifier.setSearchQuery,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _showFilterBottomSheet,
              icon: Stack(
                children: [
                  Icon(
                    LucideIcons.slidersHorizontal,
                    color: isFilterActive ? cs.primary : cs.onSurface,
                  ),
                  if (isFilterActive)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cs.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              style: IconButton.styleFrom(
                backgroundColor: isFilterActive
                    ? cs.primaryContainer.withValues(alpha: 0.5)
                    : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),

        // Active Filter Chips
        if (isFilterActive) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (isCategoryActive)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      label: Text(
                        state.selectedCategory == 'FOOD'
                            ? 'Makanan'
                            : state.selectedCategory == 'DRINK'
                            ? 'Minuman'
                            : state.selectedCategory!,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                      backgroundColor: cs.secondaryContainer,
                      onDeleted: () => notifier.setCategory(null),
                      deleteIcon: Icon(
                        LucideIcons.x,
                        size: 14,
                        color: cs.onSecondaryContainer,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                  ),
                if (isStatusActive)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      label: Text(
                        state.isActiveFilter == true ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onTertiaryContainer,
                        ),
                      ),
                      backgroundColor: cs.tertiaryContainer,
                      onDeleted: () => notifier.setIsActiveFilter(null),
                      deleteIcon: Icon(
                        LucideIcons.x,
                        size: 14,
                        color: cs.onTertiaryContainer,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(0),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                    ),
                  ),

                TextButton(
                  onPressed: () {
                    notifier.setCategory(null);
                    notifier.setIsActiveFilter(null);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Reset Semua',
                    style: TextStyle(fontSize: 12, color: cs.error),
                  ),
                ),
              ],
            ),
          ),
        ],
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
