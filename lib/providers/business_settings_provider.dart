import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/business_settings.dart';
import '../data/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

final businessSettingsProvider =
    StateNotifierProvider<
      BusinessSettingsNotifier,
      AsyncValue<BusinessSettings?>
    >((ref) {
      return BusinessSettingsNotifier(ref.watch(settingsRepositoryProvider));
    });

class BusinessSettingsNotifier
    extends StateNotifier<AsyncValue<BusinessSettings?>> {
  final SettingsRepository _repository;

  BusinessSettingsNotifier(this._repository)
    : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getBusinessSettings();
      state = AsyncValue.data(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSettings(BusinessSettings settings) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repository.updateBusinessSettings(settings);
      state = AsyncValue.data(updated);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow; // Allow UI to handle specific error toast
    }
  }
}
