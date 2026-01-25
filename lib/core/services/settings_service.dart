import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../../data/models/business_settings.dart';

class SettingsService {
  final Dio _dio = ApiClient().dio;

  Future<BusinessSettings> getBusinessSettings() async {
    try {
      final response = await _dio.get('/settings/business');
      return BusinessSettings.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to load business settings: $e');
    }
  }

  Future<BusinessSettings> updateBusinessSettings(
    BusinessSettings settings,
  ) async {
    try {
      final response = await _dio.put(
        '/settings/business',
        data: settings.toJson(),
      );
      return BusinessSettings.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update business settings: $e');
    }
  }
}
