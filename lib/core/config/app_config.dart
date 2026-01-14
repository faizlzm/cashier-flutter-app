import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';

/// App configuration with auto-detect API URL based on platform and emulator detection
class AppConfig {
  // Private constructor to prevent instantiation
  AppConfig._();

  // Cache for emulator detection result
  static bool? _isEmulatorCached;

  /// Your computer's local IP for physical device testing
  static const String localIp = '192.168.1.2';

  /// API port
  static const int apiPort = 3001;

  /// Check if running on Android emulator
  static Future<bool> isAndroidEmulator() async {
    if (_isEmulatorCached != null) return _isEmulatorCached!;

    if (!Platform.isAndroid) {
      _isEmulatorCached = false;
      return false;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      // Emulator detection based on device properties
      _isEmulatorCached =
          !androidInfo.isPhysicalDevice ||
          androidInfo.brand.toLowerCase() == 'google' &&
              androidInfo.model.toLowerCase().contains('sdk') ||
          androidInfo.fingerprint.contains('generic') ||
          androidInfo.fingerprint.contains('emulator') ||
          androidInfo.hardware.contains('goldfish') ||
          androidInfo.hardware.contains('ranchu') ||
          androidInfo.product.contains('sdk') ||
          androidInfo.product.contains('emulator');

      return _isEmulatorCached!;
    } catch (e) {
      // Default to emulator URL if detection fails
      _isEmulatorCached = true;
      return true;
    }
  }

  /// Get API base URL - use this for async initialization
  static Future<String> getApiBaseUrl() async {
    if (kIsWeb) {
      return 'http://localhost:$apiPort/api';
    }

    if (Platform.isAndroid) {
      final isEmulator = await isAndroidEmulator();
      if (isEmulator) {
        return 'http://10.0.2.2:$apiPort/api'; // Emulator
      }
      return 'http://$localIp:$apiPort/api'; // Physical device
    }

    // iOS simulator / macOS / Windows / Linux
    return 'http://localhost:$apiPort/api';
  }

  /// Sync API base URL - uses cached value or defaults to emulator URL
  /// Call getApiBaseUrl() once during app initialization to populate cache
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:$apiPort/api';
    }

    if (Platform.isAndroid) {
      // Use cached value, default to emulator URL if not yet detected
      final isEmulator = _isEmulatorCached ?? true;
      if (isEmulator) {
        return 'http://10.0.2.2:$apiPort/api';
      }
      return 'http://$localIp:$apiPort/api';
    }

    return 'http://localhost:$apiPort/api';
  }

  /// Initialize the config (call this in main.dart before runApp)
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await isAndroidEmulator();
    }
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
