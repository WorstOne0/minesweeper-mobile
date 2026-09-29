// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// Router
import '/router/app_routes.dart';
// Controllers
import '/core/controllers/ads_controller.dart';
import '/core/controllers/game_controller.dart';
import '/core/controllers/settings_controller.dart';
// Widgets
import '/features/home/widgets/app_logo.dart';
import '/widgets/my_difficulty_picker.dart';
import '/widgets/my_pill_button.dart';
import '/widgets/my_snackbar.dart';
import '/widgets/my_theme_sheet.dart';
// Utils
import '/utils/extensions/context_extensions.dart';

const githubUrl = "https://github.com/WorstOne0/Minesweeper_Flutter";

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  // Play
  Future<void> newGame() async {
    final difficulty = ref.read(settingsProvider).difficulty;
    await ref.read(adsProvider.notifier).countGame();
    if (!mounted) return;

    ref.read(gameProvider.notifier).newGame(difficulty);
    context.push(AppRoutes.game);
  }

  void resumeGame() {
    final difficulty = ref.read(settingsProvider).difficulty;
    if (!ref.read(gameProvider.notifier).resume(difficulty)) return;

    context.push(AppRoutes.game);
  }

  // Links
  Future<void> openGithub() async {
    final success = await launchUrl(Uri.parse(githubUrl), mode: LaunchMode.externalApplication);
    if (success || !mounted) return;

    context.showSnackBar(
      mySnackBar(context.colorScheme.error, Icons.error, "Could not open the link"),
    );
  }

  @override
  Widget build(BuildContext context) {
    final difficulty = ref.watch(settingsProvider.select((settings) => settings.difficulty));
    final canResume = ref.watch(
      gameProvider.select((game) => game.savedGames.contains(difficulty)),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: .topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  icon: const Icon(Icons.palette_outlined),
                  onPressed: () => MyThemeSheet.show(context),
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisSize: .min,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 48),
                  MyDifficultyPicker(
                    value: difficulty,
                    onChanged: ref.read(settingsProvider.notifier).setDifficulty,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 260,
                    child: Column(
                      spacing: 10,
                      children: [
                        if (canResume)
                          MyPillButton(label: "Resume", filled: true, onTap: resumeGame),
                        MyPillButton(label: "New game", onTap: newGame),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: .bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push(AppRoutes.settings),
                    ),
                    IconButton(
                      icon: const Icon(Icons.leaderboard_outlined),
                      onPressed: () => context.push(AppRoutes.bestTimes),
                    ),
                    IconButton(icon: const Icon(Icons.code), onPressed: openGithub),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
