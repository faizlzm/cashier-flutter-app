import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../providers/transaction_provider.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_badge.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsProvider.notifier).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(transactionsProvider);
    final isMobile = context.isMobile;

    // Show loading state
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (state.error != null && state.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(state.error!, style: TextStyle(color: cs.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(transactionsProvider.notifier).loadTransactions(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Filter transactions by search
    final allTrx = state.transactions;
    final filtered = allTrx.where((t) {
      final searchLower = _search.toLowerCase();
      return t.transactionCode.toLowerCase().contains(searchLower) ||
          t.id.toLowerCase().contains(searchLower);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header - responsive
        isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Transaksi',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppInput(
                          placeholder: 'Cari ID Transaksi...',
                          prefixIcon: Icon(
                            LucideIcons.search,
                            size: 18,
                            color: cs.onSurface.withOpacity(0.4),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          LucideIcons.filter,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          side: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ],
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
                        'Riwayat Transaksi',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pantau semua pemasukan dan detail transaksi toko Anda',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: AppInput(
                          placeholder: 'Cari ID Transaksi...',
                          prefixIcon: Icon(
                            LucideIcons.search,
                            size: 18,
                            color: cs.onSurface.withOpacity(0.4),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          LucideIcons.calendar,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          side: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          LucideIcons.filter,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          side: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        const SizedBox(height: 24),

        // Content - table for desktop, cards for mobile with pull-to-refresh
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(transactionsProvider.notifier).refresh(),
            child: isMobile
                ? _buildMobileList(theme, cs, filtered)
                : _buildDesktopTable(theme, cs, filtered),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileList(ThemeData theme, ColorScheme cs, List filtered) {
    if (filtered.isEmpty) {
      return _buildEmptyState(cs);
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final trx = filtered[i];
        final primary = trx.items.first;
        final bg = getColorFromString(primary.productName);
        final txt = getTextColorFromString(primary.productName);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        getInitials(primary.productName),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: txt,
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
                          trx.items.map((i) => i.productName).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${trx.items.length} item',
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupiah(trx.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondary.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trx.id,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: cs.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${formatDateShort(trx.date)} • ${formatTime(trx.date)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          trx.paymentMethod == 'CASH'
                              ? LucideIcons.banknote
                              : LucideIcons.creditCard,
                          size: 14,
                          color: trx.paymentMethod == 'CASH'
                              ? AppColors.green
                              : AppColors.blue,
                        ),
                        const SizedBox(width: 8),
                        AppBadge(
                          text: 'Lunas',
                          backgroundColor: AppColors.greenBg,
                          textColor: AppColors.green,
                          borderColor: AppColors.green.withOpacity(0.3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(ThemeData theme, ColorScheme cs, List filtered) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: cs.secondary.withOpacity(0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'ID',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    'Waktu',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'Metode',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Text(
                    'Total',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(cs)
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final trx = filtered[i];
                      final primary = trx.items.first;
                      final bg = getColorFromString(primary.productName);
                      final txt = getTextColorFromString(primary.productName);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.secondary.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  trx.id,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: cs.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formatDateShort(trx.date),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    formatTime(trx.date),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        getInitials(primary.productName),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: txt,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          trx.items
                                              .map((i) => i.productName)
                                              .join(', '),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${trx.items.length} item • ${primary.category == 'FOOD' ? 'Makanan' : 'Minuman'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: cs.onSurface.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  Icon(
                                    trx.paymentMethod == 'CASH'
                                        ? LucideIcons.banknote
                                        : LucideIcons.creditCard,
                                    size: 16,
                                    color: trx.paymentMethod == 'CASH'
                                        ? AppColors.green
                                        : AppColors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    trx.paymentMethod,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: AppBadge(
                                text: trx.status == 'PAID'
                                    ? 'Lunas'
                                    : trx.status,
                                backgroundColor: AppColors.greenBg,
                                textColor: AppColors.green,
                                borderColor: AppColors.green.withOpacity(0.3),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: Text(
                                formatRupiah(trx.total),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Menampilkan ${filtered.length} transaksi',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: null,
                      child: Text(
                        'Sebelumnya',
                        style: TextStyle(color: cs.onSurface.withOpacity(0.4)),
                      ),
                    ),
                    TextButton(
                      onPressed: null,
                      child: Text(
                        'Selanjutnya',
                        style: TextStyle(color: cs.onSurface.withOpacity(0.4)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.archive,
              color: cs.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi ditemukan',
            style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
