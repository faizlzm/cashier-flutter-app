import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/transaction_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../widgets/app_badge.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  int _cashReceived = 0;
  String _paymentMethod = 'CASH';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(cartProvider).isEmpty) context.go('/pos');
    });
  }

  void _handleNumpad(String value) {
    setState(() {
      if (value == 'backspace') {
        _cashReceived = _cashReceived ~/ 10;
      } else if (value == 'clear') {
        _cashReceived = 0;
      } else if (value == '000') {
        if (_cashReceived.toString().length < 10) {
          _cashReceived = int.tryParse('${_cashReceived}000') ?? _cashReceived;
        }
      } else {
        if (_cashReceived.toString().length < 12) {
          _cashReceived = int.tryParse('$_cashReceived$value') ?? _cashReceived;
        }
      }
    });
  }

  Future<void> _handlePayment() async {
    final total = ref.read(cartProvider.notifier).total;
    final change = _cashReceived - total;
    if (_paymentMethod == 'CASH' && _cashReceived < total) return;

    // Build transaction items from cart
    final cart = ref.read(cartProvider);
    final items = cart
        .map(
          (item) => TransactionItemRequest(
            productId: item.product.id,
            quantity: item.quantity,
          ),
        )
        .toList();

    // Submit to API
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final taxAmount = ref.read(cartProvider.notifier).tax;
    final transaction = await ref
        .read(checkoutProvider.notifier)
        .submitTransaction(
          items: items,
          paymentMethod: _paymentMethod,
          subtotal: subtotal,
          tax: taxAmount,
          total: total,
        );

    if (transaction != null && mounted) {
      // Clear cart after successful transaction
      ref.read(cartProvider.notifier).clearCart();

      // Navigate to success page
      context.go(
        '/pos/success',
        extra: {
          'received': _cashReceived,
          'change': change,
          'method': _paymentMethod,
          'transactionCode': transaction.transactionCode,
          'transactionId': transaction.id,
        },
      );
    } else if (mounted) {
      // Show error to user
      final errorMsg =
          ref.read(checkoutProvider).error ?? 'Gagal menyimpan transaksi';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final checkoutState = ref.watch(checkoutProvider);
    final isProcessing = checkoutState.isSubmitting;
    final total = cartNotifier.total;
    final change = (_cashReceived - total).clamp(0, double.infinity).toInt();
    final isSufficient = _paymentMethod == 'CASH'
        ? _cashReceived >= total
        : true;
    final isMobile = context.isMobile;

    List<int> quickOptions = [total];
    for (var base in [10000, 20000, 50000, 100000]) {
      final next = ((total / base).ceil() * base);
      if (next > total && !quickOptions.contains(next)) quickOptions.add(next);
    }
    quickOptions = quickOptions.toSet().toList()..sort();
    if (quickOptions.length > 4) quickOptions = quickOptions.sublist(0, 4);

    if (isMobile) {
      return _buildMobileLayout(
        theme,
        cs,
        cart,
        cartNotifier,
        total,
        change,
        isSufficient,
        quickOptions,
        isProcessing,
      );
    }

    return _buildDesktopLayout(
      theme,
      cs,
      cart,
      cartNotifier,
      total,
      change,
      isSufficient,
      quickOptions,
      isProcessing,
    );
  }

  Widget _buildMobileLayout(
    ThemeData theme,
    ColorScheme cs,
    List cart,
    CartNotifier cartNotifier,
    int total,
    int change,
    bool isSufficient,
    List<int> quickOptions,
    bool isProcessing,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => context.go('/pos'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Checkout',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Periksa pesanan sebelum bayar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Order Summary Card
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.receipt,
                        size: 18,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ringkasan Pesanan',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      AppBadge(text: '${cart.length} Item'),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.length,
                  itemBuilder: (_, i) {
                    final item = cart[i];
                    final bg = getColorFromString(item.product.name);
                    final txt = getTextColorFromString(item.product.name);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                                getInitials(item.product.name),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: txt,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${item.quantity}x @ ${formatRupiah(item.product.price)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurface.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatRupiah(item.subtotal),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.secondary.withValues(alpha: 0.3),
                  ),
                  child: Column(
                    children: [
                      _row(
                        context,
                        'Subtotal',
                        formatRupiah(cartNotifier.subtotal),
                      ),
                      const SizedBox(height: 4),
                      _row(
                        context,
                        'Pajak (11%)',
                        formatRupiah(cartNotifier.tax),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            formatRupiah(total),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Section
          Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                // Payment Methods
                Container(
                  padding: const EdgeInsets.all(12),
                  color: cs.secondary.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      Expanded(
                        child: _methodBtn(
                          context,
                          'CASH',
                          LucideIcons.banknote,
                          'Tunai',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _methodBtn(
                          context,
                          'QRIS',
                          LucideIcons.creditCard,
                          'QRIS',
                        ),
                      ),
                    ],
                  ),
                ),

                if (_paymentMethod == 'CASH') ...[
                  // Cash Input
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: cs.secondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Rp',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _cashReceived > 0
                                      ? _cashReceived
                                            .toString()
                                            .replaceAllMapped(
                                              RegExp(
                                                r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                              ),
                                              (m) => '${m[1]}.',
                                            )
                                      : '0',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_cashReceived > 0)
                                IconButton(
                                  icon: Icon(
                                    LucideIcons.delete,
                                    size: 18,
                                    color: cs.error,
                                  ),
                                  onPressed: () => _handleNumpad('clear'),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Quick options
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: quickOptions
                              .map(
                                (amt) => OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _cashReceived = amt),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    side: BorderSide(
                                      color: cs.primary.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    amt == total
                                        ? 'Pas'
                                        : '${(amt / 1000).round()}K',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: cs.primary,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        // Numpad
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 2,
                          children: [
                            '1',
                            '2',
                            '3',
                            '4',
                            '5',
                            '6',
                            '7',
                            '8',
                            '9',
                            '000',
                            '0',
                            'backspace',
                          ].map((v) => _numpadBtn(context, v)).toList(),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // QRIS
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.primary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.qrCode, size: 70),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Scan QRIS',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Menunggu pembayaran...',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Footer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Column(
                    children: [
                      if (_paymentMethod == 'CASH') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.wallet,
                                  size: 14,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Kembalian',
                                  style: TextStyle(
                                    color: cs.onSurface.withValues(alpha: 0.6),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              formatRupiah(change),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: change > 0
                                    ? Colors.green
                                    : cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (!isSufficient || isProcessing)
                              ? null
                              : _handlePayment,
                          child: isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _paymentMethod == 'CASH'
                                      ? 'Bayar ${formatRupiah(total)}'
                                      : 'Cek Status',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    ThemeData theme,
    ColorScheme cs,
    List cart,
    CartNotifier cartNotifier,
    int total,
    int change,
    bool isSufficient,
    List<int> quickOptions,
    bool isProcessing,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.arrowLeft),
                    onPressed: () => context.go('/pos'),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Checkout',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Periksa detail pesanan sebelum pembayaran',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.dividerColor),
                          ),
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
                                const Text(
                                  'Ringkasan Pesanan',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            AppBadge(text: '${cart.length} Item'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: cart.length,
                          itemBuilder: (_, i) {
                            final item = cart[i];
                            final bg = getColorFromString(item.product.name);
                            final txt = getTextColorFromString(
                              item.product.name,
                            );
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Row(
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
                                        getInitials(item.product.name),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          '${item.quantity}x @ ${formatRupiah(item.product.price)}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: cs.onSurface.withValues(
                                                  alpha: 0.6,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(item.subtotal),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.secondary.withValues(alpha: 0.3),
                        ),
                        child: Column(
                          children: [
                            _row(
                              context,
                              'Subtotal',
                              formatRupiah(cartNotifier.subtotal),
                            ),
                            const SizedBox(height: 4),
                            _row(
                              context,
                              'Pajak (11%)',
                              formatRupiah(cartNotifier.tax),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Pembayaran',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  formatRupiah(total),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: cs.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'TOTAL TAGIHAN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: cs.primary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(total),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  color: cs.secondary.withValues(alpha: 0.2),
                  child: Row(
                    children: [
                      Expanded(
                        child: _methodBtn(
                          context,
                          'CASH',
                          LucideIcons.banknote,
                          'Tunai',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _methodBtn(
                          context,
                          'QRIS',
                          LucideIcons.creditCard,
                          'QRIS',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _paymentMethod == 'CASH'
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                height: 64,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.secondary.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Rp',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _cashReceived > 0
                                            ? _cashReceived
                                                  .toString()
                                                  .replaceAllMapped(
                                                    RegExp(
                                                      r'(\d{1,3})(?=(\d{3})+(?!\d))',
                                                    ),
                                                    (m) => '${m[1]}.',
                                                  )
                                            : '0',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (_cashReceived > 0)
                                      IconButton(
                                        icon: Icon(
                                          LucideIcons.delete,
                                          size: 20,
                                          color: cs.error,
                                        ),
                                        onPressed: () => _handleNumpad('clear'),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: quickOptions
                                    .map(
                                      (amt) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          child: OutlinedButton(
                                            onPressed: () => setState(
                                              () => _cashReceived = amt,
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              side: BorderSide(
                                                color: cs.primary.withValues(
                                                  alpha: 0.3,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              amt == total
                                                  ? 'Uang Pas'
                                                  : '${(amt / 1000).round()}K',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: cs.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 1.8,
                                  children: [
                                    '1',
                                    '2',
                                    '3',
                                    '4',
                                    '5',
                                    '6',
                                    '7',
                                    '8',
                                    '9',
                                    '000',
                                    '0',
                                    'backspace',
                                  ].map((v) => _numpadBtn(context, v)).toList(),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: cs.primary.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(LucideIcons.qrCode, size: 80),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Scan QRIS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Menunggu konfirmasi pembayaran...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.dividerColor)),
                  ),
                  child: Column(
                    children: [
                      if (_paymentMethod == 'CASH') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.wallet,
                                  size: 16,
                                  color: cs.onSurface.withValues(alpha: 0.6),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kembalian',
                                  style: TextStyle(
                                    color: cs.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              formatRupiah(change),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: change > 0
                                    ? Colors.green
                                    : cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (!isSufficient || isProcessing)
                              ? null
                              : _handlePayment,
                          child: isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _paymentMethod == 'CASH'
                                      ? 'Bayar ${formatRupiah(total)}'
                                      : 'Cek Status Pembayaran',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _methodBtn(
    BuildContext context,
    String method,
    IconData icon,
    String label,
  ) {
    final cs = Theme.of(context).colorScheme;
    final isActive = _paymentMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).cardColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? cs.primary.withValues(alpha: 0.2)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? cs.primary
                  : cs.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numpadBtn(BuildContext context, String value) {
    final cs = Theme.of(context).colorScheme;
    final isBackspace = value == 'backspace';
    return Material(
      color: isBackspace
          ? Colors.red.withValues(alpha: 0.1)
          : Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleNumpad(value),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isBackspace
                  ? Colors.red.withValues(alpha: 0.3)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Center(
            child: isBackspace
                ? const Icon(LucideIcons.delete, color: Colors.red)
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
