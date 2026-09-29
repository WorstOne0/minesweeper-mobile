// Flutter packages
import 'package:material_ui/material_ui.dart';

// Utils
import '/utils/extensions/context_extensions.dart';

/// Title and explanation on the left, the control on the right.
class SettingRow extends StatelessWidget {
  const SettingRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    super.key,
  });

  final String title, subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: .opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 16, 14),
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                spacing: 3,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: .w600)),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, height: 1.35, color: context.textMuted),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
