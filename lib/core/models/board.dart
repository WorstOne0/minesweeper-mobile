// Models
import '/core/models/cell.dart';
import '/core/models/difficulty.dart';

enum GameStatus { fresh, playing, won, lost }

/// The whole game as one immutable value: every move answers a new board plus the cells it
/// opened, so the page can animate them. Mines only exist after the first reveal ([withMines]).
class Board {
  const Board({required this.difficulty, required this.cells, required this.status});

  final Difficulty difficulty;
  final List<Cell> cells;
  final GameStatus status;

  factory Board.fresh(Difficulty difficulty) => Board(
    difficulty: difficulty,
    cells: List.filled(difficulty.cellCount, const Cell()),
    status: GameStatus.fresh,
  );

  /// Lays [mines] (true per index) and counts every cell's neighbours; all cells stay hidden.
  factory Board.withMines(Difficulty difficulty, List<bool> mines) {
    final cells = List.generate(difficulty.cellCount, (index) {
      if (mines[index]) return const Cell(isMine: true);

      final around = neighboursOf(index, difficulty.rows, difficulty.columns);
      return Cell(adjacentMines: around.where((neighbour) => mines[neighbour]).length);
    });

    return Board(difficulty: difficulty, cells: cells, status: GameStatus.playing);
  }

  /// One char per cell, see [encode].
  factory Board.decode(Difficulty difficulty, String encoded) {
    final mines = [for (final char in encoded.split("")) char == "*" || char == "x" || char == "F"];
    final base = Board.withMines(difficulty, mines);
    final cells = List.generate(difficulty.cellCount, (index) {
      final state = switch (encoded[index]) {
        "r" || "x" => CellState.revealed,
        "f" || "F" => CellState.flagged,
        _ => CellState.hidden,
      };
      return base.cells[index].copyWith(state: state);
    });
    final status = switch (cells) {
      _ when encoded.contains("x") => GameStatus.lost,
      _ when cells.every((cell) => cell.isMine || cell.isRevealed) => GameStatus.won,
      _ when cells.any((cell) => cell.isRevealed) => GameStatus.playing,
      _ => GameStatus.fresh,
    };

    return Board(difficulty: difficulty, cells: cells, status: status);
  }

  int get rows => difficulty.rows;
  int get columns => difficulty.columns;
  int get mines => difficulty.mines;
  bool get isOver => status == GameStatus.won || status == GameStatus.lost;
  int get flagCount => cells.where((cell) => cell.isFlagged).length;
  int get minesLeft => status == GameStatus.won ? 0 : mines - flagCount;

  int rowOf(int index) => index ~/ columns;
  int columnOf(int index) => index % columns;
  int indexOf(int row, int column) => row * columns + column;

  List<int> neighbours(int index) => neighboursOf(index, rows, columns);

  static List<int> neighboursOf(int index, int rows, int columns) {
    final row = index ~/ columns, column = index % columns;
    final result = <int>[];

    for (var rowOffset = -1; rowOffset <= 1; rowOffset++) {
      for (var columnOffset = -1; columnOffset <= 1; columnOffset++) {
        if (rowOffset == 0 && columnOffset == 0) continue;

        final r = row + rowOffset, c = column + columnOffset;
        if (r < 0 || r >= rows || c < 0 || c >= columns) continue;

        result.add(r * columns + c);
      }
    }

    return result;
  }

  /// A hidden cell opens (and floods out from a zero); a number whose mines are all flagged
  /// opens the rest of its neighbours. Answers the cells that opened, the tapped one first.
  ({Board board, List<int> opened}) reveal(int index) {
    final cell = cells[index];
    if (cell.isFlagged || isOver) return (board: this, opened: const []);

    final next = List<Cell>.of(cells);
    final opened = <int>[];
    var exploded = false;

    void open(int start) {
      final stack = [start];
      while (stack.isNotEmpty) {
        final current = stack.removeLast();
        final target = next[current];
        if (!target.isHidden) continue;

        next[current] = target.copyWith(state: CellState.revealed);
        opened.add(current);
        if (target.isMine) {
          exploded = true;
          continue;
        }
        if (target.adjacentMines == 0) stack.addAll(neighbours(current));
      }
    }

    if (cell.isHidden) open(index);
    if (cell.isRevealed) {
      final around = neighbours(index);
      final flagged = around.where((neighbour) => next[neighbour].isFlagged).length;
      if (flagged != cell.adjacentMines) return (board: this, opened: const []);

      for (final neighbour in around) {
        open(neighbour);
      }
    }

    final status = switch (exploded) {
      true => GameStatus.lost,
      false => switch (next.every((cell) => cell.isMine || cell.isRevealed)) {
        true => GameStatus.won,
        false => GameStatus.playing,
      },
    };

    return (board: Board(difficulty: difficulty, cells: next, status: status), opened: opened);
  }

  Board toggleFlag(int index) {
    final cell = cells[index];
    if (cell.isRevealed || isOver || status == GameStatus.fresh) return this;

    final next = List<Cell>.of(cells);
    next[index] = cell.copyWith(state: cell.isFlagged ? CellState.hidden : CellState.flagged);

    return Board(difficulty: difficulty, cells: next, status: status);
  }

  /// The save file: `.` hidden, `*` hidden mine, `r` revealed, `x` the mine that ended the game,
  /// `f` flag, `F` flag on a mine. Counts are rebuilt on [decode].
  String encode() => cells.map((cell) {
    return switch ((cell.state, cell.isMine)) {
      (CellState.hidden, false) => ".",
      (CellState.hidden, true) => "*",
      (CellState.revealed, false) => "r",
      (CellState.revealed, true) => "x",
      (CellState.flagged, false) => "f",
      (CellState.flagged, true) => "F",
    };
  }).join();
}
