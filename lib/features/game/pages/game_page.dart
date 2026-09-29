// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controllers
import '/core/controllers/ads_controller.dart';
import '/core/controllers/game_controller.dart';
import '/core/controllers/settings_controller.dart';
// Models
import '/core/models/board.dart';
// Widgets
import '/features/game/widgets/board_view.dart';
import '/features/game/widgets/flag_toggle_button.dart';
import '/features/game/widgets/game_result_sheet.dart';
import '/widgets/my_difficulty_picker.dart';
import '/widgets/my_pill_button.dart';
import '/widgets/my_theme_sheet.dart';
// Utils
import '/utils/extensions/duration_extensions.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => GamePageState();
}

class GamePageState extends ConsumerState<GamePage> with WidgetsBindingObserver {
  bool flagMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(gameProvider.notifier).pause();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(gameProvider.notifier);
    if (state == AppLifecycleState.paused) controller.pause();
    if (state == AppLifecycleState.resumed) controller.unpause();
  }

  // Play
  Future<void> startNewGame() async {
    final difficulty = ref.read(settingsProvider).difficulty;
    await ref.read(adsProvider.notifier).countGame();
    if (!mounted) return;

    ref.read(gameProvider.notifier).newGame(difficulty);
    setState(() => flagMode = false);
  }

  void onCellTap(int index) {
    final controller = ref.read(gameProvider.notifier);
    final cell = ref.read(gameProvider).board.cells[index];

    if (flagMode && !cell.isRevealed) {
      controller.toggleFlag(index);
      return;
    }
    controller.reveal(index);
  }

  void onCellLongPress(int index) {
    HapticFeedback.mediumImpact();
    ref.read(gameProvider.notifier).toggleFlag(index);
  }

  void showResult() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted || !ref.read(gameProvider).board.isOver) return;
      GameResultSheet.show(context, onNewGame: startNewGame);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameProvider.select((game) => game.board.status), (previous, status) {
      if (status == GameStatus.won || status == GameStatus.lost) showResult();
    });

    final game = ref.watch(gameProvider);
    final settings = ref.watch(settingsProvider);
    final board = game.board;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: .min,
          spacing: 20,
          children: [
            Row(
              mainAxisSize: .min,
              spacing: 5,
              children: [
                const Icon(Icons.bug_report_outlined, size: 18),
                Text("${board.minesLeft}"),
              ],
            ),
            Row(
              mainAxisSize: .min,
              spacing: 5,
              children: [const Icon(Icons.timer_outlined, size: 18), Text(game.elapsed.clock)],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => MyThemeSheet.show(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: BoardView(
                    board: board,
                    lastMove: game.lastMove,
                    longPress: settings.longPress,
                    onTap: onCellTap,
                    onLongPress: onCellLongPress,
                  ),
                ),
                if (game.isGenerating)
                  const Align(alignment: .topCenter, child: LinearProgressIndicator(minHeight: 2)),
                if (settings.flagToggle && !board.isOver)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FlagToggleButton(
                      active: flagMode,
                      onTap: () => setState(() => flagMode = !flagMode),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Column(
                spacing: 6,
                children: [
                  SizedBox(
                    width: 260,
                    child: MyPillButton(label: "Start new game", onTap: startNewGame),
                  ),
                  MyDifficultyPicker(
                    value: settings.difficulty,
                    onChanged: ref.read(settingsProvider.notifier).setDifficulty,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
