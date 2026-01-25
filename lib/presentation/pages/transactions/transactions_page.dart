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

  void _showFilterBottomSheet() {
    final state = ref.read(transactionsProvider);
    DateTime? tempStartDate = state.startDate;
    DateTime? tempEndDate = state.endDate;
    String? tempStatus = state.status;
    String? tempPaymentMethod = state.paymentMethod;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final cs = theme.colorScheme;

            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Transaksi',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Reset local state
                          setState(() {
                            tempStartDate = null;
                            tempEndDate = null;
                            tempStatus = null;
                            tempPaymentMethod = null;
                          });
                        },
                        child: Text('Reset', style: TextStyle(color: cs.error)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Date Filters
                  Text(
                    'Tanggal',
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
                        label: 'Semua Tanggal',
                        selected: tempStartDate == null,
                        onSelected: (_) => setState(() {
                          tempStartDate = null;
                          tempEndDate = null;
                        }),
                      ),
                      _buildFilterChip(
                        label: 'Hari Ini',
                        selected:
                            _isSameDay(tempStartDate, DateTime.now()) &&
                            tempEndDate == null, // Simplified logic for demo
                        onSelected: (_) => setState(() {
                          final now = DateTime.now();
                          tempStartDate = DateTime(
                            now.year,
                            now.month,
                            now.day,
                          );
                          tempEndDate = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            23,
                            59,
                            59,
                          );
                        }),
                      ),
                      ActionChip(
                        label: Text(
                          (tempStartDate != null && tempEndDate != null)
                              ? '${formatDateShort(tempStartDate!)} - ${formatDateShort(tempEndDate!)}'
                              : 'Pilih Tanggal',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                (tempStartDate != null && tempEndDate != null)
                                ? cs.onPrimary
                                : cs.onSurface,
                          ),
                        ),
                        avatar: Icon(
                          LucideIcons.calendar,
                          size: 16,
                          color: (tempStartDate != null && tempEndDate != null)
                              ? cs.onPrimary
                              : cs.onSurface.withValues(alpha: 0.6),
                        ),
                        backgroundColor:
                            (tempStartDate != null && tempEndDate != null)
                            ? cs.primary
                            : null,
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDateRange:
                                (tempStartDate != null && tempEndDate != null)
                                ? DateTimeRange(
                                    start: tempStartDate!,
                                    end: tempEndDate!,
                                  )
                                : null,
                          );
                          if (picked != null) {
                            setState(() {
                              tempStartDate = picked.start;
                              tempEndDate = picked.end;
                            });
                          }
                        },
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
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        selected: tempStatus == null,
                        onSelected: (_) => setState(() => tempStatus = null),
                      ),
                      _buildFilterChip(
                        label: 'Lunas',
                        selected: tempStatus == 'PAID',
                        onSelected: (_) => setState(() => tempStatus = 'PAID'),
                      ),
                      _buildFilterChip(
                        label: 'Pending',
                        selected: tempStatus == 'PENDING',
                        onSelected: (_) =>
                            setState(() => tempStatus = 'PENDING'),
                      ),
                      _buildFilterChip(
                        label: 'Batal',
                        selected: tempStatus == 'CANCELLED',
                        onSelected: (_) =>
                            setState(() => tempStatus = 'CANCELLED'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Payment Method Section
                  Text(
                    'Metode Pembayaran',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        selected: tempPaymentMethod == null,
                        onSelected: (_) =>
                            setState(() => tempPaymentMethod = null),
                      ),
                      _buildFilterChip(
                        label: 'Tunai',
                        selected: tempPaymentMethod == 'CASH',
                        onSelected: (_) =>
                            setState(() => tempPaymentMethod = 'CASH'),
                      ),
                      _buildFilterChip(
                        label: 'QRIS',
                        selected: tempPaymentMethod == 'QRIS',
                        onSelected: (_) =>
                            setState(() => tempPaymentMethod = 'QRIS'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref
                            .read(transactionsProvider.notifier)
                            .setFilters(
                              startDate: tempStartDate,
                              endDate: tempEndDate,
                              status: tempStatus,
                              paymentMethod: tempPaymentMethod,
                            );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
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

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Theme.of(context).colorScheme.onPrimary : null,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? Colors.transparent : Theme.of(context).dividerColor,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final state = ref.watch(transactionsProvider);
    final isMobile = context.isMobile;

    // Check active filters for UI state
    final isDateFilterActive = state.startDate != null || state.endDate != null;
    final isStatusFilterActive =
        state.status != null || state.paymentMethod != null;

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

    // Filter transactions by search (client-side for search only)
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
                          placeholder: 'Cari Kode Transaksi...',
                          prefixIcon: Icon(
                            LucideIcons.search,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showFilterBottomSheet,
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              LucideIcons.slidersHorizontal,
                              color:
                                  (isDateFilterActive || isStatusFilterActive)
                                  ? cs.primary
                                  : cs.onSurface.withValues(alpha: 0.6),
                            ),
                            if (isDateFilterActive || isStatusFilterActive)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: cs.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          side: BorderSide(
                            color: (isDateFilterActive || isStatusFilterActive)
                                ? cs.primary
                                : theme.dividerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Riwayat Transaksi',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: AppInput(
                          placeholder: 'Cari Kode Transaksi...',
                          prefixIcon: Icon(
                            LucideIcons.search,
                            size: 18,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          ),
                          onChanged: (v) => setState(() => _search = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showFilterBottomSheet,
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              LucideIcons.slidersHorizontal,
                              color:
                                  (isDateFilterActive || isStatusFilterActive)
                                  ? cs.primary
                                  : cs.onSurface.withValues(alpha: 0.6),
                            ),
                            if (isDateFilterActive || isStatusFilterActive)
                              Positioned(
                                top: -2,
                                right: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: cs.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.cardColor,
                          side: BorderSide(
                            color: (isDateFilterActive || isStatusFilterActive)
                                ? cs.primary
                                : theme.dividerColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

        // Active Filters Chips
        if (isDateFilterActive || isStatusFilterActive) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (state.startDate != null && state.endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        '${formatDateShort(state.startDate!)} - ${formatDateShort(state.endDate!)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      avatar: const Icon(LucideIcons.calendar, size: 14),
                      deleteIcon: const Icon(LucideIcons.x, size: 14),
                      onDeleted: () {
                        ref
                            .read(transactionsProvider.notifier)
                            .setFilters(
                              startDate: null,
                              endDate: null,
                              status: state.status,
                              paymentMethod: state.paymentMethod,
                            );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: theme.dividerColor),
                      backgroundColor: theme.cardColor,
                    ),
                  ),
                if (state.status != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        state.status == 'PAID'
                            ? 'Lunas'
                            : state.status == 'PENDING'
                            ? 'Pending'
                            : 'Batal',
                        style: const TextStyle(fontSize: 12),
                      ),
                      avatar: const Icon(LucideIcons.checkCircle, size: 14),
                      deleteIcon: const Icon(LucideIcons.x, size: 14),
                      onDeleted: () {
                        ref
                            .read(transactionsProvider.notifier)
                            .setFilters(
                              startDate: state.startDate,
                              endDate: state.endDate,
                              status: null,
                              paymentMethod: state.paymentMethod,
                            );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: theme.dividerColor),
                      backgroundColor: theme.cardColor,
                    ),
                  ),
                if (state.paymentMethod != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        state.paymentMethod == 'CASH' ? 'Tunai' : 'QRIS',
                        style: const TextStyle(fontSize: 12),
                      ),
                      avatar: const Icon(LucideIcons.wallet, size: 14),
                      deleteIcon: const Icon(LucideIcons.x, size: 14),
                      onDeleted: () {
                        ref
                            .read(transactionsProvider.notifier)
                            .setFilters(
                              startDate: state.startDate,
                              endDate: state.endDate,
                              status: state.status,
                              paymentMethod: null,
                            );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: theme.dividerColor),
                      backgroundColor: theme.cardColor,
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    ref.read(transactionsProvider.notifier).resetFilters();
                  },
                  child: const Text(
                    'Reset Semua',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],

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
                            color: cs.onSurface.withValues(alpha: 0.5),
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
                  color: cs.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.secondary.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              trx.transactionCode,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${formatDateShort(trx.date)} • ${formatTime(trx.date)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          text: trx.status == 'PAID'
                              ? 'Lunas'
                              : trx.status == 'CANCELLED'
                              ? 'Batal'
                              : 'Pending',
                          backgroundColor: trx.status == 'PAID'
                              ? AppColors.greenBg
                              : trx.status == 'CANCELLED'
                              ? AppColors.destructiveLight.withValues(
                                  alpha: 0.1,
                                )
                              : AppColors.orange.withValues(alpha: 0.1),
                          textColor: trx.status == 'PAID'
                              ? AppColors.green
                              : trx.status == 'CANCELLED'
                              ? AppColors.destructiveLight
                              : AppColors.orange,
                          borderColor: trx.status == 'PAID'
                              ? AppColors.green.withValues(alpha: 0.3)
                              : trx.status == 'CANCELLED'
                              ? AppColors.destructiveLight.withValues(
                                  alpha: 0.3,
                                )
                              : AppColors.orange.withValues(alpha: 0.3),
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
              color: cs.secondary.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'Kode',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: Text(
                    'Waktu',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'Metode',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withValues(alpha: 0.6),
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
                      color: cs.onSurface.withValues(alpha: 0.6),
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
                              color: theme.dividerColor.withValues(alpha: 0.5),
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
                                  color: cs.secondary.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  trx.transactionCode,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: cs.onSurface.withValues(alpha: 0.7),
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
                                      color: cs.onSurface.withValues(
                                        alpha: 0.5,
                                      ),
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
                                            color: cs.onSurface.withValues(
                                              alpha: 0.5,
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
                                    : trx.status == 'CANCELLED'
                                    ? 'Batal'
                                    : 'Pending',
                                backgroundColor: trx.status == 'PAID'
                                    ? AppColors.greenBg
                                    : trx.status == 'CANCELLED'
                                    ? AppColors.destructiveLight.withValues(
                                        alpha: 0.1,
                                      )
                                    : AppColors.orange.withValues(alpha: 0.1),
                                textColor: trx.status == 'PAID'
                                    ? AppColors.green
                                    : trx.status == 'CANCELLED'
                                    ? AppColors.destructiveLight
                                    : AppColors.orange,
                                borderColor: trx.status == 'PAID'
                                    ? AppColors.green.withValues(alpha: 0.3)
                                    : trx.status == 'CANCELLED'
                                    ? AppColors.destructiveLight.withValues(
                                        alpha: 0.3,
                                      )
                                    : AppColors.orange.withValues(alpha: 0.3),
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
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: null,
                      child: Text(
                        'Sebelumnya',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: null,
                      child: Text(
                        'Selanjutnya',
                        style: TextStyle(
                          color: cs.onSurface.withValues(alpha: 0.4),
                        ),
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
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada transaksi ditemukan',
            style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba ubah filter pencarian Anda',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
