// Flutter packages
import 'package:material_ui/material_ui.dart';

extension StringExtension on String {
  Color toColor() {
    String hexColor = replaceAll("#", "");
    return Color(int.parse("0xFF$hexColor"));
  }

  // To correct the TextOverflow.ellipsis
  // ** FOR SHOW PURPOSES ONLY ** - Like inside Text Widgets
  String tight() {
    return Characters(this)
        .replaceAll(Characters(' '), Characters('\u{000A0}'))
        .replaceAll(Characters('-'), Characters('\u{2011}'))
        .toString();
  }

  bool get isEmail => RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  String get capitalize => isEmpty ? this : this[0].toUpperCase() + substring(1);

  bool get isNumeric => double.tryParse(this) != null;
}
