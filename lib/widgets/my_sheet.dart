// Flutter packages
import 'package:material_ui/material_ui.dart';

// Utils
import '/utils/extensions/context_extensions.dart';

/// Eyebrow, title and subtitle at the top of a sheet page, with room for a back
/// arrow on one side and an action on the other.
class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
  });

  final String eyebrow, title, subtitle;
  final Widget? leading, trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: 12,
        children: [
          ?leading,
          Expanded(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: context.textSubtle),
                ),
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: .bold)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: context.textMuted)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Tappable row of a sheet — icon block, label, and either a chevron through to
/// the next page or a check when it is a choice.
class SheetRow extends StatelessWidget {
  const SheetRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Count shown over the icon block when the row is filtering something down.
  final String? badge;

  /// Null draws a chevron, otherwise the row reads as picked or not.
  final bool? selected;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorScheme.primary;
    final isSelected = selected ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: .zero,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            spacing: 10,
            children: [
              Stack(
                clipBehavior: .none,
                children: [
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: accent.withValues(alpha: 0.12),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: .bold,
                            color: context.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              Expanded(
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      title,
                      overflow: .ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: .bold),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        overflow: .ellipsis,
                        style: TextStyle(fontSize: 12, color: context.textMuted),
                      ),
                  ],
                ),
              ),

              switch (selected) {
                null => Icon(Icons.keyboard_arrow_right, color: context.textMuted),
                _ => Icon(
                  switch (isSelected) {
                    true => Icons.verified,
                    false => Icons.circle_outlined,
                  },
                  color: switch (isSelected) {
                    true => accent,
                    false => context.textSubtle,
                  },
                ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

/// Filled button that closes a sheet page.
class SheetPrimaryButton extends StatelessWidget {
  const SheetPrimaryButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: .center,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: context.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: .bold, color: context.colorScheme.onPrimary),
        ),
      ),
    );
  }
}
