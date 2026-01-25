import '../../core/services/settings_service.dart';
import '../../data/models/business_settings.dart';

class SettingsRepository {
  final SettingsService _settingsService = SettingsService();

  Future<BusinessSettings> getBusinessSettings() async {
    return await _settingsService.getBusinessSettings();
  }

  Future<BusinessSettings> updateBusinessSettings(
    BusinessSettings settings,
  ) async {
    return await _settingsService.updateBusinessSettings(settings);
  }
}
