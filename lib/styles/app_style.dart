// Flutter packages
import 'package:material_ui/material_ui.dart';

// Styles
import 'style_config.dart';

/// The theme picker's rows: the page colour and the accent hidden cells wear on it.
enum AppTheme {
  nebula("Nebula", Color(0xff0b0912), Color(0xff8b6cff), isDark: true),
  sand("Sand", Color(0xff1f1e1b), Color(0xffbfae6c), isDark: true),
  sky("Sky", Color(0xff12181f), Color(0xff30b9f6), isDark: true),
  ember("Ember", Color(0xff2a2826), Color(0xfff28b1d), isDark: true),
  moss("Moss", Color(0xff161a16), Color(0xff55b35b), isDark: true),
  orchid("Orchid", Color(0xff0f0b11), Color(0xffd650ba), isDark: true),
  cream("Cream", Color(0xfff8f6f0), Color(0xffbda86a), isDark: false),
  steel("Steel", Color(0xfff5f8fb), Color(0xff6b9cc4), isDark: false),
  rose("Rose", Color(0xfffcf7f7), Color(0xffc75c63), isDark: false);

  const AppTheme(this.label, this.background, this.accent, {required this.isDark});

  final String label;
  final Color background, accent;
  final bool isDark;

  static AppTheme of(String? value) =>
      values.firstWhere((theme) => theme.name == value, orElse: () => nebula);
}

class AppStyle {
  static ThemeData of(AppTheme theme) => themeData(theme);
}
