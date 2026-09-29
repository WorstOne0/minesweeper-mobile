// Dart
import 'dart:async';

// Flutter packages
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Controllers
import '/core/controllers/best_times_controller.dart';
// Models
import '/core/models/board.dart';
import '/core/models/board_generator.dart';
import '/core/models/difficulty.dart';
// Repositories
import '/core/repositories/game_repository.dart';

@immutable
class GameState {
  const GameState({
    required this.board,
    required this.elapsed,
    required this.savedGames,
    this.lastMove,
    this.rank,
    this.winId,
    this.isGenerating = false,
  });

  final Board board;
  final Duration elapsed;

  /// Difficulties with a game to resume; the home page reads it.
  final Set<Difficulty> savedGames;

  /// The tapped cell and everything it opened, for the reveal cascade.
  final ({int origin, List<int> opened})? lastMove;

  /// Where the last win landed in the top five (null when it did not make it) and its id.
  final int? rank, winId;

  /// True while the first reveal waits for a guess-free layout.
  final bool isGenerating;

  GameState copyWith({
    Board? board,
    Duration? elapsed,
    Set<Difficulty>? savedGames,
    ({int origin, List<int> opened})? lastMove,
    int? rank,
    int? winId,
    bool? isGenerating,
  }) => GameState(
    board: board ?? this.board,
    elapsed: elapsed ?? this.elapsed,
    savedGames: savedGames ?? this.savedGames,
    lastMove: lastMove ?? this.lastMove,
    rank: rank ?? this.rank,
    winId: winId ?? this.winId,
    isGenerating: isGenerating ?? this.isGenerating,
  );
}

class GameController extends Notifier<GameState> {
  late final GameRepository repository;
  Timer? timer;

  @override
  GameState build() {
    repository = ref.watch(gameRepositoryProvider);
    ref.onDispose(stopTimer);

    return GameState(
      board: Board.fresh(Difficulty.easy),
      elapsed: Duration.zero,
      savedGames: {
        for (final difficulty in Difficulty.values)
          if (repository.savedGame(difficulty) != null) difficulty,
      },
    );
  }

  // Start
  void newGame(Difficulty difficulty) {
    stopTimer();
    repository.clearGame(difficulty);

    state = GameState(
      board: Board.fresh(difficulty),
      elapsed: Duration.zero,
      savedGames: {...state.savedGames}..remove(difficulty),
    );
  }

  /// Answers false when there is nothing saved for [difficulty].
  bool resume(Difficulty difficulty) {
    final saved = repository.savedGame(difficulty);
    if (saved == null) return false;

    stopTimer();
    state = GameState(
      board: Board.decode(difficulty, saved.cells),
      elapsed: Duration(seconds: saved.seconds),
      savedGames: state.savedGames,
    );
    unpause();

    return true;
  }

  // Moves
  Future<void> reveal(int index) async {
    var board = state.board;
    if (board.isOver || state.isGenerating) return;

    if (board.status == GameStatus.fresh) {
      state = state.copyWith(isGenerating: true);

      final difficulty = board.difficulty;
      final mines = await compute(generateMines, (
        rows: difficulty.rows,
        columns: difficulty.columns,
        mines: difficulty.mines,
        safeIndex: index,
      ));
      board = Board.withMines(difficulty, mines);
      startTimer();
    }

    final move = board.reveal(index);
    state = state.copyWith(
      board: move.board,
      lastMove: (origin: index, opened: move.opened),
      isGenerating: false,
    );
    afterMove();
  }

  void toggleFlag(int index) {
    final board = state.board.toggleFlag(index);
    if (identical(board, state.board)) return;

    state = state.copyWith(board: board);
    afterMove();
  }

  void afterMove() {
    final board = state.board;
    final difficulty = board.difficulty;

    if (!board.isOver) {
      repository.saveGame(difficulty, board.encode(), state.elapsed.inSeconds);
      state = state.copyWith(savedGames: {...state.savedGames, difficulty});
      return;
    }

    stopTimer();
    repository.clearGame(difficulty);
    final savedGames = {...state.savedGames}..remove(difficulty);
    if (board.status == GameStatus.lost) {
      state = state.copyWith(savedGames: savedGames);
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch;
    final rank = ref.read(bestTimesProvider.notifier).record(difficulty, state.elapsed, id: id);
    state = state.copyWith(savedGames: savedGames, rank: rank, winId: id);
  }

  // Clock — the page pauses it when it leaves the screen or the app goes to the background.
  void pause() {
    stopTimer();

    final board = state.board;
    if (board.status != GameStatus.playing) return;
    repository.saveGame(board.difficulty, board.encode(), state.elapsed.inSeconds);
  }

  void unpause() {
    if (state.board.status == GameStatus.playing) startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1));
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }
}

final gameProvider = NotifierProvider<GameController, GameState>(GameController.new);
