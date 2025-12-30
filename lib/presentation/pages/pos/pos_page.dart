import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../providers/cart_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_badge.dart';

class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  String _search = '';
  String _category = 'ALL';
  bool _showCart = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final allProducts = ProductRepository().getAll();
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final isMobile = context.isMobile;

    final filteredProducts = allProducts.where((p) {
      final matchSearch = p.name.toLowerCase().contains(_search.toLowerCase());
      final matchCat = _category == 'ALL' || p.category == _category;
      return matchSearch && matchCat;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // In landscape mode, we have more width so use desktop-style layout
    final useMobileLayout = isMobile && !context.isLandscape;

    // Mobile portrait layout
    if (useMobileLayout) {
      return Stack(
        children: [
          Column(
            children: [
              // Search & Filter - scrollable horizontal
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 200,
                        child: AppInput(
                          placeholder: 'Cari produk...',
                          prefixIcon: Icon(
                            LucideIcons.search,
                            size: 18,
                            color: cs.onSurface.withOpacity(0.4),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Semua',
                        variant: _category == 'ALL' ? BtnVariant.primary : BtnVariant.outline,
                        size: BtnSize.sm,
                        onPressed: () => setState(() => _category = 'ALL'),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Makanan',
                        variant: _category == 'FOOD' ? BtnVariant.primary : BtnVariant.outline,
                        size: BtnSize.sm,
                        onPressed: () => setState(() => _category = 'FOOD'),
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: 'Minuman',
                        variant: _category == 'DRINK' ? BtnVariant.primary : BtnVariant.outline,
                        size: BtnSize.sm,
                        onPressed: () => setState(() => _category = 'DRINK'),
                      ),
                    ],
                  ),
                ),
              ),

              // Product List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (_, i) => _buildProductItem(filteredProducts[i], theme, cs, cartNotifier),
                ),
              ),
              
              // Bottom spacing for cart FAB
              const SizedBox(height: 80),
            ],
          ),
          
          // Floating Cart Button
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _showCart = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.shoppingCart, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Keranjang (${cartNotifier.itemCount})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatRupiah(cartNotifier.total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Cart Bottom Sheet
          if (_showCart)
            _buildMobileCartSheet(theme, cs, cart, cartNotifier),
        ],
      );
    }

    // Desktop layout
    return Row(
      children: [
        // Product List (Left)
        Expanded(
          child: Column(
            children: [
              // Search & Filter
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      placeholder: 'Cari produk...',
                      prefixIcon: Icon(
                        LucideIcons.search,
                        size: 18,
                        color: cs.onSurface.withOpacity(0.4),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    text: 'Semua',
                    variant: _category == 'ALL' ? BtnVariant.primary : BtnVariant.outline,
                    onPressed: () => setState(() => _category = 'ALL'),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: 'Makanan',
                    variant: _category == 'FOOD' ? BtnVariant.primary : BtnVariant.outline,
                    onPressed: () => setState(() => _category = 'FOOD'),
                  ),
                  const SizedBox(width: 8),
                  AppButton(
                    text: 'Minuman',
                    variant: _category == 'DRINK' ? BtnVariant.primary : BtnVariant.outline,
                    onPressed: () => setState(() => _category = 'DRINK'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Product List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (_, i) => _buildProductItem(filteredProducts[i], theme, cs, cartNotifier),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Cart (Right)
        _buildDesktopCart(theme, cs, cart, cartNotifier),
      ],
    );
  }

  Widget _buildProductItem(dynamic p, ThemeData theme, ColorScheme cs, CartNotifier cartNotifier) {
    final bgColor = getColorFromString(p.name);
    final txtColor = getTextColorFromString(p.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => cartNotifier.addItem(p),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      getInitials(p.name),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: txtColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        formatRupiah(p.price),
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.plus, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCartSheet(ThemeData theme, ColorScheme cs, List cart, CartNotifier cartNotifier) {
    return GestureDetector(
      onTap: () => setState(() => _showCart = false),
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: cs.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Cart Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.secondary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.shoppingCart, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Keranjang',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              AppBadge(text: cartNotifier.itemCount.toString()),
                            ],
                          ),
                          Row(
                            children: [
                              if (cart.isNotEmpty)
                                IconButton(
                                  icon: Icon(LucideIcons.trash2, size: 18, color: cs.error),
                                  onPressed: () => cartNotifier.clearCart(),
                                ),
                              IconButton(
                                icon: const Icon(LucideIcons.x, size: 20),
                                onPressed: () => setState(() => _showCart = false),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Cart Items
                    Expanded(
                      child: cart.isEmpty
                          ? _buildEmptyCart(cs)
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: cart.length,
                              itemBuilder: (_, i) => _buildCartItem(cart[i], theme, cs, cartNotifier),
                            ),
                    ),

                    // Cart Footer
                    _buildCartFooter(theme, cs, cart, cartNotifier),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopCart(ThemeData theme, ColorScheme cs, List cart, CartNotifier cartNotifier) {
    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // Cart Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.secondary.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.shoppingCart, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Keranjang',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    AppBadge(text: cartNotifier.itemCount.toString()),
                  ],
                ),
                if (cart.isNotEmpty)
                  IconButton(
                    icon: Icon(LucideIcons.trash2, size: 18, color: cs.error),
                    onPressed: () => cartNotifier.clearCart(),
                  ),
              ],
            ),
          ),

          // Cart Items
          Expanded(
            child: cart.isEmpty
                ? _buildEmptyCart(cs)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (_, i) => _buildCartItem(cart[i], theme, cs, cartNotifier),
                  ),
          ),

          // Cart Footer
          _buildCartFooter(theme, cs, cart, cartNotifier),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.shoppingCart,
            size: 48,
            color: cs.onSurface.withOpacity(0.2),
          ),
          const SizedBox(height: 8),
          Text(
            'Keranjang kosong',
            style: TextStyle(color: cs.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(dynamic item, ThemeData theme, ColorScheme cs, CartNotifier cartNotifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                getInitials(item.product.name),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatRupiah(item.product.price),
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _qtyBtn(
                      context,
                      LucideIcons.minus,
                      () => cartNotifier.updateQuantity(
                        item.product.id,
                        item.quantity - 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _qtyBtn(
                      context,
                      LucideIcons.plus,
                      () => cartNotifier.updateQuantity(
                        item.product.id,
                        item.quantity + 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(item.subtotal),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => cartNotifier.removeItem(item.product.id),
                child: Icon(
                  LucideIcons.trash2,
                  size: 16,
                  color: cs.error.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartFooter(ThemeData theme, ColorScheme cs, List cart, CartNotifier cartNotifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.secondary.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Column(
        children: [
          _totalRow(context, 'Subtotal', formatRupiah(cartNotifier.subtotal)),
          const SizedBox(height: 4),
          _totalRow(context, 'PPN (11%)', formatRupiah(cartNotifier.tax)),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatRupiah(cartNotifier.total),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: cart.isEmpty ? null : () {
                setState(() => _showCart = false);
                context.go('/pos/checkout');
              },
              child: const Text(
                'Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }

  Widget _totalRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
