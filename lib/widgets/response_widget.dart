// Flutter packages
import 'package:material_ui/material_ui.dart';

// Utils
import '/utils/extensions/context_extensions.dart';

/// Empty, error and "nothing found" states. Every screen ends up here when it has
/// no rows to draw, so the shape stays the same and only the words change.
class ResponseWidget extends StatelessWidget {
  const ResponseWidget({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.action,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title, subtitle;

  /// Way out of the state — "Limpar busca", "Tentar de novo". Use [MyResponseAction].
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: .min,
          spacing: 8,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: .center,
              style: const TextStyle(fontSize: 17, fontWeight: .bold),
            ),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                subtitle,
                textAlign: .center,
                style: TextStyle(fontSize: 13, height: 1.35, color: context.textMuted),
              ),
            ),

            if (action != null) const SizedBox(height: 8),
            ?action,
          ],
        ),
      ),
    );
  }
}

/// Button under a [ResponseWidget]. Filled when it is the obvious next tap,
/// outlined when it only retries what already failed.
class MyResponseAction extends StatelessWidget {
  const MyResponseAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = true,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: switch (filled) {
            true => accent,
            false => Colors.transparent,
          },
          border: Border.all(
            color: switch (filled) {
              true => accent,
              false => context.colorScheme.outline,
            },
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: .min,
          spacing: 8,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 16,
                color: switch (filled) {
                  true => context.colorScheme.onPrimary,
                  false => accent,
                },
              ),
            Text(
              label,
              style: TextStyle(
                fontWeight: .bold,
                color: switch (filled) {
                  true => context.colorScheme.onPrimary,
                  false => accent,
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
