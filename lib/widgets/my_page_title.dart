// Flutter packages
import 'package:material_ui/material_ui.dart';

/// The big light title under a transparent app bar — Settings, Best times.
class MyPageTitle extends StatelessWidget {
  const MyPageTitle({required this.title, super.key});

  final String title;

  static const double size = 30;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      child: Text(
        title,
        style: const TextStyle(fontSize: size, fontWeight: .w300, letterSpacing: -0.3),
      ),
    );
  }
}
