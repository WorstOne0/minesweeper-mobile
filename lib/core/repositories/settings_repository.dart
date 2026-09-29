// Flutter packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
import '/core/models/difficulty.dart';
// Services
import '/services/storage/hive_storage.dart';
// Styles
import '/styles/app_style.dart';

class SettingsRepository {
  const SettingsRepository({required this.storage});

  final HiveStorage storage;

  AppTheme get theme => AppTheme.of(storage.read("theme"));
  Difficulty get difficulty => Difficulty.of(storage.read("difficulty"));
  bool get flagToggle => storage.read("flag_toggle") != "false";
  int get longPressMs => int.tryParse(storage.read("long_press_ms") ?? "") ?? 300;
  int get gamesSinceAd => int.tryParse(storage.read("games_since_ad") ?? "") ?? 0;

  Future<void> saveTheme(AppTheme theme) => storage.save("theme", theme.name);
  Future<void> saveDifficulty(Difficulty difficulty) => storage.save("difficulty", difficulty.name);
  Future<void> saveFlagToggle(bool value) => storage.save("flag_toggle", "$value");
  Future<void> saveLongPressMs(int value) => storage.save("long_press_ms", "$value");
  Future<void> saveGamesSinceAd(int value) => storage.save("games_since_ad", "$value");
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(storage: ref.watch(hiveStorageProvider));
});
