// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Router
import '/router/app_routes.dart';
// Controllers
import '/core/controllers/ads_controller.dart';
import '/core/controllers/best_times_controller.dart';
import '/core/controllers/game_controller.dart';
import '/core/controllers/settings_controller.dart';
// Models
import '/core/models/difficulty.dart';
// Widgets
import '/widgets/my_difficulty_picker.dart';
import '/widgets/my_page_title.dart';
import '/widgets/my_times_list.dart';
import '/widgets/response_widget.dart';
// Utils
import '/utils/extensions/context_extensions.dart';

class BestTimesPage extends ConsumerStatefulWidget {
  const BestTimesPage({super.key});

  @override
  ConsumerState<BestTimesPage> createState() => BestTimesPageState();
}

class BestTimesPageState extends ConsumerState<BestTimesPage> {
  Difficulty difficulty = Difficulty.easy;

  @override
  void initState() {
    super.initState();
    difficulty = ref.read(settingsProvider).difficulty;
  }

  Future<void> play() async {
    ref.read(settingsProvider.notifier).setDifficulty(difficulty);
    await ref.read(adsProvider.notifier).countGame();
    if (!mounted) return;

    ref.read(gameProvider.notifier).newGame(difficulty);
    context.push(AppRoutes.game);
  }

  @override
  Widget build(BuildContext context) {
    final times = ref.watch(bestTimesProvider).of(difficulty);

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: .start,
        children: [
          const MyPageTitle(title: "Best times"),
          Center(
            child: MyDifficultyPicker(
              value: difficulty,
              onChanged: (value) => setState(() => difficulty = value),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: switch (times.isEmpty) {
              true => ResponseWidget(
                icon: Icons.timer_outlined,
                iconColor: context.colorScheme.primary,
                title: "No times yet",
                subtitle: "Finish a game on ${difficulty.label} and it lands here.",
                action: MyResponseAction(label: "Play", icon: Icons.play_arrow, onTap: play),
              ),
              false => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MyTimesList(times: times),
              ),
            },
          ),
        ],
      ),
    );
  }
}
