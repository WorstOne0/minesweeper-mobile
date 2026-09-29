// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Styles
import 'app_style.dart';

// ─────────────────────────────────────────────────────────────
// COLOR SCHEME — one flat page colour and one accent; every other role is a tone of the page.
// The board reads: primary = hidden cell, secondaryContainer = flag block, error = the mine
// that ended the game, outlineVariant = the grid hairline, onSurfaceVariant = the numbers.
// ─────────────────────────────────────────────────────────────
ColorScheme colorScheme(AppTheme theme) {
  final page = theme.background;
  final accent = theme.accent;
  final ink = theme.isDark ? Colors.white : Colors.black;
  Color tone(double amount) => Color.lerp(page, ink, amount)!;

  final accentIsLight = ThemeData.estimateBrightnessForColor(accent) == Brightness.light;

  return ColorScheme(
    brightness: theme.isDark ? Brightness.dark : Brightness.light,

    primary: accent,
    onPrimary: accentIsLight ? const Color(0xff1c1b18) : Colors.white,
    primaryContainer: Color.alphaBlend(accent.withValues(alpha: 0.14), page),
    onPrimaryContainer: accent,

    secondary: tone(0.55),
    onSecondary: page,
    secondaryContainer: tone(theme.isDark ? 0.30 : 0.42),
    onSecondaryContainer: Colors.white,

    error: theme.isDark ? const Color(0xffe25b52) : const Color(0xffc8251b),
    onError: Colors.white,

    surface: page,
    onSurface: tone(0.90),
    onSurfaceVariant: tone(0.62),
    surfaceContainerLowest: theme.isDark ? tone(0.02) : Colors.white,
    surfaceContainerLow: tone(0.03),
    surfaceContainer: tone(0.06),
    surfaceContainerHigh: tone(0.10),
    surfaceContainerHighest: tone(0.14),

    outline: tone(0.40),
    outlineVariant: tone(theme.isDark ? 0.14 : 0.12),
    surfaceTint: Colors.transparent,
    shadow: Colors.black,
    scrim: Colors.black,
  );
}

// ─────────────────────────────────────────────────────────────
// TYPE — Inter everywhere. google_fonts builds flutter/material text themes, not material_ui
// ones, so only its family name is borrowed; the clock and counters ask for tabular figures.
// ─────────────────────────────────────────────────────────────
const tabularFigures = [FontFeature.tabularFigures()];

TextTheme textTheme(ColorScheme colors, bool isDark) {
  final base = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

  return base.apply(
    fontFamily: GoogleFonts.inter().fontFamily,
    bodyColor: colors.onSurface,
    displayColor: colors.onSurface,
  );
}

// ─────────────────────────────────────────────────────────────
// SHAPE
// ─────────────────────────────────────────────────────────────
ShapeBorder get shapeSmall => RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
ShapeBorder get shapeMedium => RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
ShapeBorder get shapeLarge => RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

// ─────────────────────────────────────────────────────────────
// COMPONENT THEMES
// ─────────────────────────────────────────────────────────────
AppBarTheme appBarTheme(ColorScheme colors, TextTheme text, bool isDark) => AppBarTheme(
  elevation: 0,
  scrolledUnderElevation: 0,
  backgroundColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  foregroundColor: colors.onSurface,
  centerTitle: true,
  titleTextStyle: text.titleSmall?.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    fontFeatures: tabularFigures,
  ),
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
  ),
);

CardThemeData cardTheme(ColorScheme colors) => CardThemeData(
  elevation: 0,
  surfaceTintColor: Colors.transparent,
  color: colors.surfaceContainerLow,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: colors.outlineVariant),
  ),
);

DialogThemeData dialogTheme(ColorScheme colors) => DialogThemeData(
  backgroundColor: colors.surface,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  shape: shapeLarge,
);

BottomSheetThemeData bottomSheetTheme(ColorScheme colors) => BottomSheetThemeData(
  backgroundColor: colors.surface,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
);

SliderThemeData sliderTheme(ColorScheme colors) => SliderThemeData(
  activeTrackColor: colors.primary,
  inactiveTrackColor: colors.outlineVariant,
  thumbColor: colors.primary,
  overlayColor: colors.primary.withValues(alpha: 0.12),
  valueIndicatorColor: colors.primary,
  trackHeight: 3,
);

SwitchThemeData switchTheme(ColorScheme colors) => SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.selected) ? colors.onPrimary : colors.outline,
  ),
  trackColor: WidgetStateProperty.resolveWith(
    (states) =>
        states.contains(WidgetState.selected) ? colors.primary : colors.surfaceContainerHigh,
  ),
  trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
);

ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colors) => ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: colors.primary,
    foregroundColor: colors.onPrimary,
    elevation: 0,
    shadowColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
  ),
);

TextButtonThemeData textButtonTheme(ColorScheme colors) => TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: colors.primary,
    textStyle: const TextStyle(fontWeight: FontWeight.w600),
  ),
);

// ─────────────────────────────────────────────────────────────
// THEME ASSEMBLY
// ─────────────────────────────────────────────────────────────
ThemeData themeData(AppTheme theme) {
  final colors = colorScheme(theme);
  final text = textTheme(colors, theme.isDark);
  final base = theme.isDark ? ThemeData.dark() : ThemeData.light();

  return base.copyWith(
    scaffoldBackgroundColor: colors.surface,
    colorScheme: colors,
    textTheme: text,
    iconTheme: IconThemeData(color: colors.onSurfaceVariant),
    appBarTheme: appBarTheme(colors, text, theme.isDark),
    cardTheme: cardTheme(colors),
    dialogTheme: dialogTheme(colors),
    bottomSheetTheme: bottomSheetTheme(colors),
    sliderTheme: sliderTheme(colors),
    switchTheme: switchTheme(colors),
    elevatedButtonTheme: elevatedButtonTheme(colors),
    textButtonTheme: textButtonTheme(colors),
    dividerColor: colors.outlineVariant,
    splashColor: colors.primary.withValues(alpha: 0.12),
    highlightColor: colors.primary.withValues(alpha: 0.06),
  );
}
