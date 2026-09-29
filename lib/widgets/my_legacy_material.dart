// Flutter packages
import 'package:material_ui/material_ui.dart';

/// Feeds a legacy `Theme` and `MaterialLocalizations` to wolt_modal_sheet, still built against
/// `package:flutter/material.dart`. Delete once it ships a material_ui build.
class MyLegacyMaterial extends StatelessWidget {
  const MyLegacyMaterial({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return MaterialUiCompatibilityBridge(child: child);
  }
}
