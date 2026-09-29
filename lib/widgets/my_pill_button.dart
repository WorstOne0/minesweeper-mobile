// Flutter packages
import 'package:material_ui/material_ui.dart';

// Utils
import '/utils/extensions/context_extensions.dart';

/// The app's button: a pill, outlined by default and filled when it is the obvious next tap.
class MyPillButton extends StatelessWidget {
  const MyPillButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool filled;

  static const double height = 48;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final foreground = filled ? colors.onPrimary : colors.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: .center,
        decoration: BoxDecoration(
          color: filled ? colors.primary : null,
          border: filled ? null : Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(height / 2),
        ),
        child: Row(
          mainAxisSize: .min,
          spacing: 8,
          children: [
            if (icon != null) Icon(icon, size: 18, color: foreground),
            Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: .w500, color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
