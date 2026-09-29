// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// The artwork over the wordmark. The art carries its own dark glow, so it sits best on the
/// dark themes.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  static const double size = 220;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      spacing: 2,
      children: [
        Image.asset("assets/images/logo.png", width: size, height: size),
        Text(
          "</> CodeSweeper",
          style: TextStyle(fontFamily: GoogleFonts.firaCode().fontFamily, fontSize: 24),
        ),
      ],
    );
  }
}
