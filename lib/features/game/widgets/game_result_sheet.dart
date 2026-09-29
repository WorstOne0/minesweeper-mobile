// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

// Controllers
import '/core/controllers/best_times_controller.dart';
import '/core/controllers/game_controller.dart';
// Models
import '/core/models/board.dart';
// Widgets
import '/widgets/my_sheet.dart';
import '/widgets/my_times_list.dart';
// Utils
import '/utils/extensions/context_extensions.dart';
import '/utils/extensions/duration_extensions.dart';

/// "Neat!" with the top five after a win, "Boom!" with a retry after a loss.
class GameResultSheet extends ConsumerWidget {
  const GameResultSheet({required this.onNewGame, super.key});

  final VoidCallback onNewGame;

  static Future<void> show(BuildContext context, {required VoidCallback onNewGame}) =>
      WoltModalSheet.show(
        context: context,
        modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
        pageListBuilder: (sheetContext) => [
          WoltModalSheetPage(
            hasTopBarLayer: false,
            backgroundColor: sheetContext.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            child: GameResultSheet(onNewGame: onNewGame),
          ),
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final board = game.board;
    final won = board.status == GameStatus.won;
    final times = ref.watch(bestTimesProvider).of(board.difficulty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Column(
        mainAxisSize: .min,
        spacing: 12,
        children: [
          SheetHeader(
            eyebrow: board.difficulty.label,
            title: won ? "Neat!" : "Boom!",
            subtitle: won
                ? "Solved in ${game.elapsed.clock}"
                : "A bug got you after ${game.elapsed.clock}",
          ),
          if (won && times.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: MyTimesList(times: times, highlightId: game.winId),
            ),
          SheetPrimaryButton(
            label: won ? "Got it!" : "Try again",
            onTap: () {
              Navigator.of(context).pop();
              if (!won) onNewGame();
            },
          ),
          if (!won)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Look at the board"),
            ),
        ],
      ),
    );
  }
}
