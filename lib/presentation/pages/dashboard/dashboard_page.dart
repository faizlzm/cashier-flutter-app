import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../providers/dashboard_provider.dart';
import '../../widgets/app_badge.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load dashboard specific data
      ref.read(dashboardProvider.notifier).loadDashboardData();
      // Also load products for count
      // ref.read(productsProvider.notifier).loadProducts(); // Usually loaded by app init
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dashboardState = ref.watch(dashboardProvider);
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    final stats = [
      {
        'label': 'Pendapatan Hari Ini',
        'value': formatRupiah(dashboardState.todayRevenue),
        'icon': LucideIcons.dollarSign,
        'trend': '${dashboardState.todayCount} transaksi hari ini',
        'color': AppColors.green,
        'bg': AppColors.greenBg,
      },
      {
        'label': 'Total Transaksi',
        'value': dashboardState.todayCount.toString(),
        'icon': LucideIcons.receipt,
        'trend': 'Hari ini',
        'color': AppColors.blue,
        'bg': AppColors.blueBg,
      },
      {
        'label': 'Produk Aktif',
        'value': dashboardState.totalProducts.toString(),
        'icon': LucideIcons.package,
        'trend': '${dashboardState.lowStockProducts} stok rendah',
        'color': AppColors.orange,
        'bg': AppColors.orangeBg,
      },
      {
        'label': 'Status',
        'value': dashboardState.isLoading ? 'Loading...' : 'Online',
        'icon': LucideIcons.activity,
        'trend': 'Terhubung ke server',
        'color': AppColors.purple,
        'bg': AppColors.purpleBg,
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
      gridAspectRatio = 2.0;
    } else if (isMobile) {
      gridColumns = 2;
      gridAspectRatio = 1.3;
    } else if (isTablet) {
      gridColumns = 2;
      gridAspectRatio = 1.4;
    } else {
      gridColumns = 4;
      gridAspectRatio = 1.6;
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 14,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatDateId(DateTime.now()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
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
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 16,
                            color: cs.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatDateId(DateTime.now()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
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
                              color: cs.onSurface.withValues(alpha: 0.6),
                              fontSize: isMobile ? 10 : 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: EdgeInsets.all(isMobile ? 4 : 6),
                          decoration: BoxDecoration(
                            color: s['bg'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            s['icon'] as IconData,
                            size: isMobile ? 12 : 14,
                            color: s['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
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
                        Icon(
                          LucideIcons.trendingUp,
                          size: isMobile ? 8 : 10,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            s['trend'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.6),
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
                    _buildTransactionsCard(
                      context,
                      theme,
                      cs,
                      dashboardState.recentTransactions,
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _buildTransactionsCard(
                        context,
                        theme,
                        cs,
                        dashboardState.recentTransactions,
                      ),
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
          gradient: LinearGradient(
            colors: [cs.primary, cs.primary.withBlue(255)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.shoppingCart,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Icon(
                  LucideIcons.arrowRight,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ],
            ),
            SizedBox(height: context.isMobile ? 16 : 24),
            Text(
              'Mulai Transaksi Baru',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.isMobile ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Masuk ke halaman Point of Sale',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: context.isMobile ? 12 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
  ) {
    final isMobile = context.isMobile;
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.clock,
                size: 16,
                color: cs.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Shift Saat Ini',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _shiftRow(
            context,
            LucideIcons.clock,
            'Waktu Mulai',
            '08:00 WIB',
            AppColors.blueBg,
            AppColors.blue,
          ),
          const SizedBox(height: 12),
          _shiftRow(
            context,
            LucideIcons.user,
            'Kasir Bertugas',
            'Admin User',
            AppColors.purpleBg,
            AppColors.purple,
          ),
          const SizedBox(height: 12),
          _shiftRow(
            context,
            LucideIcons.wallet,
            'Saldo Awal',
            'Rp 200.000',
            AppColors.greenBg,
            AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    List transactions,
  ) {
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
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 20,
              vertical: isMobile ? 12 : 16,
            ),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.receipt,
                      size: 18,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Transaksi Terakhir',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        LucideIcons.arrowRight,
                        size: 14,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Belum ada transaksi hari ini',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
            )
          else
            ...transactions
                .take(isMobile ? 3 : 5)
                .map(
                  (trx) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 20,
                      vertical: isMobile ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: isMobile ? 32 : 40,
                          height: isMobile ? 32 : 40,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              getInitials(
                                trx.items.isNotEmpty
                                    ? trx.items.first.productName
                                    : 'TX',
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                                fontSize: isMobile ? 10 : 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trx.items.map((i) => i.productName).join(', '),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: isMobile ? 12 : 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${trx.transactionCode} • ${formatTime(trx.createdAt)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                  fontFamily: 'monospace',
                                  fontSize: isMobile ? 9 : 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatRupiah(trx.total),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AppBadge(
                              text: 'Lunas',
                              backgroundColor: AppColors.greenBg,
                              textColor: AppColors.green,
                              borderColor: AppColors.green.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _shiftRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color bg,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: isMobile ? 14 : 16, color: color),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: isMobile ? 10 : 11,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
