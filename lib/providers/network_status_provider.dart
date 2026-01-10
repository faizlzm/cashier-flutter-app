import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connection status
enum NetworkStatus { online, offline, unknown }

/// Network status state
class NetworkState {
  final NetworkStatus status;
  final List<ConnectivityResult> connectionTypes;
  final bool isChecking;

  const NetworkState({
    this.status = NetworkStatus.unknown,
    this.connectionTypes = const [],
    this.isChecking = false,
  });

  bool get isOnline => status == NetworkStatus.online;
  bool get isOffline => status == NetworkStatus.offline;

  NetworkState copyWith({
    NetworkStatus? status,
    List<ConnectivityResult>? connectionTypes,
    bool? isChecking,
  }) {
    return NetworkState(
      status: status ?? this.status,
      connectionTypes: connectionTypes ?? this.connectionTypes,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  /// Get connection type description
  String get connectionDescription {
    if (connectionTypes.isEmpty) return 'Tidak diketahui';

    final types = connectionTypes.map((t) {
      switch (t) {
        case ConnectivityResult.wifi:
          return 'WiFi';
        case ConnectivityResult.mobile:
          return 'Data Seluler';
        case ConnectivityResult.ethernet:
          return 'Ethernet';
        case ConnectivityResult.bluetooth:
          return 'Bluetooth';
        case ConnectivityResult.vpn:
          return 'VPN';
        case ConnectivityResult.other:
          return 'Lainnya';
        case ConnectivityResult.none:
          return 'Tidak ada';
      }
    });

    return types.join(', ');
  }
}

/// Network status notifier
class NetworkStatusNotifier extends StateNotifier<NetworkState> {
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkStatusNotifier({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity(),
      super(const NetworkState()) {
    _init();
  }

  void _init() {
    // Check initial status
    checkConnection();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  /// Check current connection status
  Future<void> checkConnection() async {
    state = state.copyWith(isChecking: true);

    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      state = state.copyWith(status: NetworkStatus.unknown, isChecking: false);
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final hasConnection =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    state = NetworkState(
      status: hasConnection ? NetworkStatus.online : NetworkStatus.offline,
      connectionTypes: results,
      isChecking: false,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Global network status provider
final networkStatusProvider =
    StateNotifierProvider<NetworkStatusNotifier, NetworkState>(
      (ref) => NetworkStatusNotifier(),
    );

/// Convenience provider for checking if online
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(networkStatusProvider).isOnline;
});

/// Convenience provider for checking if offline
final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(networkStatusProvider).isOffline;
});
