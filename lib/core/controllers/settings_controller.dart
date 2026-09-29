// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
import '/core/models/difficulty.dart';
// Repositories
import '/core/repositories/settings_repository.dart';
// Styles
import '/styles/app_style.dart';

@immutable
class SettingsState {
  const SettingsState({
    required this.theme,
    required this.difficulty,
    required this.flagToggle,
    required this.longPressMs,
  });

  final AppTheme theme;
  final Difficulty difficulty;
  final bool flagToggle;
  final int longPressMs;

  Duration get longPress => Duration(milliseconds: longPressMs);

  SettingsState copyWith({
    AppTheme? theme,
    Difficulty? difficulty,
    bool? flagToggle,
    int? longPressMs,
  }) => SettingsState(
    theme: theme ?? this.theme,
    difficulty: difficulty ?? this.difficulty,
    flagToggle: flagToggle ?? this.flagToggle,
    longPressMs: longPressMs ?? this.longPressMs,
  );
}

class SettingsController extends Notifier<SettingsState> {
  late final SettingsRepository repository;

  @override
  SettingsState build() {
    repository = ref.watch(settingsRepositoryProvider);

    return SettingsState(
      theme: repository.theme,
      difficulty: repository.difficulty,
      flagToggle: repository.flagToggle,
      longPressMs: repository.longPressMs,
    );
  }

  void setTheme(AppTheme theme) {
    state = state.copyWith(theme: theme);
    repository.saveTheme(theme);
  }

  void setDifficulty(Difficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
    repository.saveDifficulty(difficulty);
  }

  void setFlagToggle(bool value) {
    state = state.copyWith(flagToggle: value);
    repository.saveFlagToggle(value);
  }

  void setLongPressMs(int value) {
    state = state.copyWith(longPressMs: value);
    repository.saveLongPressMs(value);
  }
}

final settingsProvider = NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);
