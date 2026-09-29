// Flutter packages
import 'package:material_ui/material_ui.dart';

// Utils
import '/utils/extensions/context_extensions.dart';

/// Floats over the board: while active, a tap flags instead of opening.
class FlagToggleButton extends StatelessWidget {
  const FlagToggleButton({required this.active, required this.onTap, super.key});

  final bool active;
  final VoidCallback onTap;

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: .circle,
          color: active ? colors.primary : colors.surface,
          border: Border.all(color: active ? colors.primary : colors.outline),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8)],
        ),
        child: Icon(Icons.flag, color: active ? colors.onPrimary : colors.onSurfaceVariant),
      ),
    );
  }
}
