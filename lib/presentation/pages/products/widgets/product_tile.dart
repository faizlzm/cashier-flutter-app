import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/product_model.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const ProductTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bgColor = getColorFromString(product.name);
    final txtColor = getTextColorFromString(product.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Opacity(
        opacity: product.isActive ? 1.0 : 0.6,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    getInitials(product.name),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: txtColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Name
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Row 2: Category icon + text • Stok
                    Row(
                      children: [
                        Icon(
                          product.category == 'FOOD'
                              ? LucideIcons.utensilsCrossed
                              : LucideIcons.coffee,
                          size: 12,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          product.category == 'FOOD' ? 'Makanan' : 'Minuman',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          '  •  ',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                        Text(
                          'Stok: ${product.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.isLowStock || product.isOutOfStock
                                ? Colors.orange
                                : cs.onSurface.withValues(alpha: 0.5),
                            fontWeight:
                                product.isLowStock || product.isOutOfStock
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        if (!product.isActive) ...[
                          const SizedBox(width: 8),
                          _buildBadge('Nonaktif', cs.secondary, cs.onSecondary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Row 3: Price
                    Text(
                      formatRupiah(product.price),
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Menu
              PopupMenuButton<String>(
                icon: Icon(
                  LucideIcons.moreVertical,
                  size: 20,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;
                    case 'toggle':
                      onToggleActive();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(LucideIcons.pencil, size: 16, color: cs.onSurface),
                        const SizedBox(width: 8),
                        const Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          product.isActive
                              ? LucideIcons.powerOff
                              : LucideIcons.power,
                          size: 16,
                          color: cs.onSurface,
                        ),
                        const SizedBox(width: 8),
                        Text(product.isActive ? 'Nonaktifkan' : 'Aktifkan'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LucideIcons.trash2, size: 16, color: cs.error),
                        const SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: cs.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: bgColor,
        ),
      ),
    );
  }
}
