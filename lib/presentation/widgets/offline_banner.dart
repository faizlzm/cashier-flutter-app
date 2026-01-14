import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/network_status_provider.dart';
import '../../providers/offline_sync_provider.dart';

/// Offline banner that appears at top of screen when network is unavailable
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = ref.watch(networkStatusProvider);
    final syncState = ref.watch(offlineSyncProvider);
    final pendingCount = syncState.pendingCount;

    // Don't show banner if online and no pending transactions
    if (networkState.isOnline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    // Don't show if still checking and no pending
    if (networkState.status == NetworkStatus.unknown && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    // Determine banner content based on state
    final bool isOffline = networkState.isOffline;
    final bool isSyncing = syncState.isSyncing;

    String message;
    Color backgroundColor;
    IconData icon;

    if (isOffline && pendingCount > 0) {
      message = 'Mode Offline - $pendingCount transaksi menunggu sync';
      backgroundColor = Colors.orange.shade800;
      icon = LucideIcons.wifiOff;
    } else if (isOffline) {
      message = 'Tidak ada koneksi internet';
      backgroundColor = Colors.orange.shade800;
      icon = LucideIcons.wifiOff;
    } else if (isSyncing) {
      message = 'Menyinkronkan $pendingCount transaksi...';
      backgroundColor = Colors.blue.shade700;
      icon = LucideIcons.refreshCw;
    } else if (pendingCount > 0) {
      message = '$pendingCount transaksi menunggu sync';
      backgroundColor = Colors.amber.shade700;
      icon = LucideIcons.clock;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSyncing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else if (isOffline && networkState.isChecking)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else if (isOffline)
              GestureDetector(
                onTap: () =>
                    ref.read(networkStatusProvider.notifier).checkConnection(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (pendingCount > 0)
              GestureDetector(
                onTap: () => ref.read(offlineSyncProvider.notifier).syncNow(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Sync Sekarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper that shows offline banner above child content
class NetworkAwareScaffold extends ConsumerWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const NetworkAwareScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
