// Flutter packages
import 'package:material_ui/material_ui.dart';

// Models
import '/core/models/difficulty.dart';

/// `<  Easy  >` — steps through [Difficulty.values] and wraps at both ends.
class MyDifficultyPicker extends StatelessWidget {
  const MyDifficultyPicker({required this.value, required this.onChanged, super.key});

  final Difficulty value;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: .min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => onChanged(value.previous),
        ),
        SizedBox(
          width: 120,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              value.label,
              key: ValueKey(value),
              textAlign: .center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => onChanged(value.next),
        ),
      ],
    );
  }
}
