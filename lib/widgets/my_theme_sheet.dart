// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

// Controllers
import '/core/controllers/settings_controller.dart';
// Styles
import '/styles/app_style.dart';
// Widgets
import '/widgets/my_sheet.dart';
// Utils
import '/utils/extensions/context_extensions.dart';

/// Theme picker: one dot per [AppTheme], the page colour as its ring and the accent as its centre.
/// Tapping applies at once, so the page behind shows the change while the sheet stays open.
class MyThemeSheet extends ConsumerWidget {
  const MyThemeSheet({super.key});

  static Future<void> show(BuildContext context) => WoltModalSheet.show(
    context: context,
    modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
    pageListBuilder: (sheetContext) => [
      WoltModalSheetPage(
        hasTopBarLayer: false,
        backgroundColor: sheetContext.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        child: const MyThemeSheet(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(settingsProvider).theme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Column(
        mainAxisSize: .min,
        spacing: 12,
        children: [
          SheetHeader(eyebrow: "Theme", title: "Colours", subtitle: selected.label),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
              alignment: .center,
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final theme in AppTheme.values)
                  ThemeDot(
                    theme: theme,
                    selected: theme == selected,
                    onTap: () => ref.read(settingsProvider.notifier).setTheme(theme),
                  ),
              ],
            ),
          ),
          SheetPrimaryButton(label: "Done", onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class ThemeDot extends StatelessWidget {
  const ThemeDot({required this.theme, required this.selected, required this.onTap, super.key});

  final AppTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final onAccent = theme.isDark ? theme.background : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          shape: .circle,
          color: theme.background,
          border: Border.all(
            color: selected ? theme.accent : context.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(shape: .circle, color: theme.accent),
            child: selected ? Icon(Icons.check, size: 15, color: onAccent) : null,
          ),
        ),
      ),
    );
  }
}
