// Flutter packages
import 'package:material_ui/material_ui.dart';

extension BuildContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  Brightness get brightness => theme.brightness;
  bool get isDark => theme.brightness == Brightness.dark;

  // Muted text colors for secondary/tertiary copy (labels, subtitles, hints).
  Color get textMuted => colorScheme.onSurfaceVariant;
  Color get textSubtle => colorScheme.onSurfaceVariant.withValues(alpha: 0.65);

  // MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get deviceSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  // Navigation
  NavigatorState get navigator => Navigator.of(this);

  // Scaffold / Snackbar
  ScaffoldMessengerState get scaffold => ScaffoldMessenger.of(this);
  void showSnackBar(SnackBar snackBar) => scaffold
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
