import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../widgets/app_badge.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final transactions = TransactionRepository().getAll();
    final products = ProductRepository().getAll();
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    final stats = [
      {
        'label': 'Pendapatan Hari Ini',
        'value': formatRupiah(1750000),
        'icon': LucideIcons.dollarSign,
        'trend': '+20.1% dari kemarin',
        'color': AppColors.green,
        'bg': AppColors.greenBg
      },
      {
        'label': 'Total Transaksi',
        'value': '12',
        'icon': LucideIcons.receipt,
        'trend': '5 total bulan ini',
        'color': AppColors.blue,
        'bg': AppColors.blueBg
      },
      {
        'label': 'Produk Aktif',
        'value': products.length.toString(),
        'icon': LucideIcons.package,
        'trend': 'Dalam katalog',
        'color': AppColors.orange,
        'bg': AppColors.orangeBg
      },
      {
        'label': 'Pelanggan',
        'value': '89',
        'icon': LucideIcons.users,
        'trend': '+4 sejak jam terakhir',
        'color': AppColors.purple,
        'bg': AppColors.purpleBg
      },
    ];

    // Check for landscape mode with limited height
    final isLandscape = context.isLandscape;
    final isCompactHeight = context.isCompactHeight;

    // Determine grid columns based on screen size and orientation
    int gridColumns;
    double gridAspectRatio;
    
    if (isCompactHeight && isLandscape) {
      // Landscape mode - use 4 columns with wider aspect ratio
      gridColumns = 4;
      gridAspectRatio = 1.8;
    } else if (isMobile) {
      gridColumns = 2;
      gridAspectRatio = 1.1;
    } else if (isTablet) {
      gridColumns = 2;
      gridAspectRatio = 1.2;
    } else {
      gridColumns = 4;
      gridAspectRatio = 1.3;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - responsive
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.clock, size: 14, color: cs.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 6),
                          Text(
                            formatDateId(DateTime.now()),
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ringkasan aktivitas bisnis Anda hari ini',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.clock, size: 16, color: cs.onSurface.withOpacity(0.6)),
                          const SizedBox(width: 8),
                          Text(
                            formatDateId(DateTime.now()),
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          // Stats Grid - responsive columns
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns,
              crossAxisSpacing: isMobile ? 8 : 16,
              mainAxisSpacing: isMobile ? 8 : 16,
              childAspectRatio: gridAspectRatio,
            ),
            itemCount: stats.length,
            itemBuilder: (_, i) {
              final s = stats[i];
              return Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            s['label'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                              fontSize: isMobile ? 10 : 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.all(isMobile ? 4 : 6),
                          decoration: BoxDecoration(color: s['bg'] as Color, borderRadius: BorderRadius.circular(8)),
                          child: Icon(s['icon'] as IconData, size: isMobile ? 12 : 14, color: s['color'] as Color),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      s['value'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(LucideIcons.trendingUp, size: isMobile ? 8 : 10, color: AppColors.green),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s['trend'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                              fontSize: isMobile ? 9 : 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Bottom Section - responsive
          isMobile
              ? Column(
                  children: [
                    // Quick Action Card
                    _buildQuickActionCard(context, cs),
                    const SizedBox(height: 16),
                    // Current Shift
                    _buildShiftCard(context, theme, cs),
                    const SizedBox(height: 16),
                    // Recent Transactions
                    _buildTransactionsCard(context, theme, cs, transactions),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildTransactionsCard(context, theme, cs, transactions),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _buildQuickActionCard(context, cs),
                          const SizedBox(height: 16),
                          _buildShiftCard(context, theme, cs),
                        ],
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, ColorScheme cs) {
    return GestureDetector(
      onTap: () => context.go('/pos'),
      child: Container(
        padding: EdgeInsets.all(context.isMobile ? 16 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [cs.primary, cs.primary.withBlue(255)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: cs.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.shoppingCart, color: Colors.white, size: 28),
                ),
                Icon(LucideIcons.arrowRight, color: Colors.white.withOpacity(0.7)),
              ],
            ),
            SizedBox(height: context.isMobile ? 16 : 24),
            Text('Mulai Transaksi Baru', style: TextStyle(color: Colors.white, fontSize: context.isMobile ? 16 : 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Masuk ke halaman Point of Sale', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: context.isMobile ? 12 : 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(BuildContext context, ThemeData theme, ColorScheme cs) {
    final isMobile = context.isMobile;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.dividerColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(LucideIcons.clock, size: 16, color: cs.onSurface.withOpacity(0.6)),
            const SizedBox(width: 8),
            Text('Shift Saat Ini', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          _shiftRow(context, LucideIcons.clock, 'Waktu Mulai', '08:00 WIB', AppColors.blueBg, AppColors.blue),
          const SizedBox(height: 12),
          _shiftRow(context, LucideIcons.user, 'Kasir Bertugas', 'Admin User', AppColors.purpleBg, AppColors.purple),
          const SizedBox(height: 12),
          _shiftRow(context, LucideIcons.wallet, 'Saldo Awal', 'Rp 200.000', AppColors.greenBg, AppColors.green),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard(BuildContext context, ThemeData theme, ColorScheme cs, List transactions) {
    final isMobile = context.isMobile;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 12 : 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(LucideIcons.receipt, size: 18, color: cs.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text('Transaksi Terakhir', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ]),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: Row(children: [
                    Text('Lihat Semua', style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6))),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.arrowRight, size: 14, color: cs.onSurface.withOpacity(0.6)),
                  ]),
                ),
              ],
            ),
          ),
          ...transactions.take(isMobile ? 3 : 5).map((trx) => Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: isMobile ? 10 : 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)))),
            child: Row(children: [
              Container(
                width: isMobile ? 32 : 40, 
                height: isMobile ? 32 : 40,
                decoration: BoxDecoration(color: cs.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text(getInitials(trx.items.first.name), style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary, fontSize: isMobile ? 10 : 12))),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  trx.items.map((i) => i.name).join(', '), 
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: isMobile ? 12 : 14), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
                Text('${trx.id} • ${formatTime(trx.date)}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.5), fontFamily: 'monospace', fontSize: isMobile ? 9 : 11)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formatRupiah(trx.total), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: isMobile ? 12 : 14)),
                const SizedBox(height: 4),
                AppBadge(text: 'Lunas', backgroundColor: AppColors.greenBg, textColor: AppColors.green, borderColor: AppColors.green.withOpacity(0.3)),
              ]),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _shiftRow(BuildContext context, IconData icon, String label, String value, Color bg, Color color) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(color: theme.colorScheme.secondary.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Container(padding: EdgeInsets.all(isMobile ? 6 : 8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: isMobile ? 14 : 16, color: color)),
        SizedBox(width: isMobile ? 8 : 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: isMobile ? 10 : 11)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: isMobile ? 12 : 14)),
        ]),
      ]),
    );
  }
}
