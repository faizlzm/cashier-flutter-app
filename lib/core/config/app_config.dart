import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// App configuration with auto-detect API URL based on platform
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  /// API base URL - auto-detected based on platform
  static String get apiBaseUrl {
    // Override URL for real devices (uncomment and set your IP)
    // const overrideUrl = 'http://192.168.1.x:3001/api';
    // return overrideUrl;

    if (kIsWeb) {
      // Web runs in browser on same machine
      return 'http://localhost:3001/api';
    }

    if (Platform.isAndroid) {
      // Android emulator uses special IP to reach host localhost
      return 'http://10.0.2.2:3001/api';
    }

    // iOS simulator / macOS / Windows / Linux
    return 'http://localhost:3001/api';
  }

  /// API timeout duration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  /// Token storage keys
  static const String accessTokenKey = 'cashier_access_token';
  static const String refreshTokenKey = 'cashier_refresh_token';

  /// Local database name (for offline cache)
  static const String databaseName = 'cashier_cache.db';

  /// Cache expiry duration for products (24 hours)
  static const Duration productsCacheExpiry = Duration(hours: 24);
}
