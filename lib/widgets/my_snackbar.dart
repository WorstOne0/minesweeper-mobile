// Flutter packages
import 'package:material_ui/material_ui.dart';

// Utils
import '/utils/extensions/string_extensions.dart';

SnackBar mySnackBar(
  Color color,
  IconData icon,
  String text, {
  // Only work well for 3 maxLines
  int maxLines = 2,
  Duration? duration,
  SnackBarBehavior behavior = SnackBarBehavior.floating,
}) {
  //
  return SnackBar(
    behavior: behavior,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    dismissDirection: DismissDirection.horizontal,
    duration: duration ?? const Duration(seconds: 2),
    padding: EdgeInsets.zero,
    content: SizedBox(
      // Only work well for 3 maxLines.
      // User another thing for text bigger than that
      height: switch (maxLines == 2) {
        true => 60,
        false => 75,
      },
      child: Row(
        children: [
          Container(
            width: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      text.tight(),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
