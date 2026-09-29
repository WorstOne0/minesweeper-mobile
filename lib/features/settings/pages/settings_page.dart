// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controllers
import '/core/controllers/settings_controller.dart';
// Widgets
import '/features/settings/widgets/setting_row.dart';
import '/widgets/my_page_title.dart';
import '/widgets/my_theme_sheet.dart';
// Utils
import '/utils/extensions/context_extensions.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          const MyPageTitle(title: "Settings"),
          SettingRow(
            title: "Flag toggle",
            subtitle:
                "A button in the corner of the board that switches taps between opening "
                "and flagging.",
            trailing: Switch(value: settings.flagToggle, onChanged: controller.setFlagToggle),
          ),
          SettingRow(
            title: "Long tap delay",
            subtitle:
                "How long to hold a cell to flag it. Too short and the system stops telling "
                "simple taps from long ones.",
            trailing: Text(
              "${settings.longPressMs} ms",
              style: TextStyle(color: context.textMuted),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: settings.longPressMs.toDouble(),
              min: 150,
              max: 1000,
              divisions: 17,
              onChanged: (value) => controller.setLongPressMs(value.round()),
            ),
          ),
          SettingRow(
            title: "Theme",
            subtitle: settings.theme.label,
            trailing: Icon(Icons.chevron_right, color: context.textMuted),
            onTap: () => MyThemeSheet.show(context),
          ),
        ],
      ),
    );
  }
}
