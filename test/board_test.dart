// Flutter packages
import 'package:flutter_test/flutter_test.dart';
// Models
import 'package:minesweeper/core/models/board.dart';
import 'package:minesweeper/core/models/board_generator.dart';
import 'package:minesweeper/core/models/cell.dart';
import 'package:minesweeper/core/models/difficulty.dart';

void main() {
  test("every difficulty generates a layout the solver finishes without guessing", () {
    for (final difficulty in Difficulty.values) {
      final layout = (
        rows: difficulty.rows,
        columns: difficulty.columns,
        mines: difficulty.mines,
        safeIndex: difficulty.cellCount ~/ 2,
      );
      final neighbours = [
        for (var index = 0; index < difficulty.cellCount; index++)
          Board.neighboursOf(index, difficulty.rows, difficulty.columns),
      ];

      var slowest = 0;
      for (var run = 0; run < 10; run++) {
        final watch = Stopwatch()..start();
        final mines = generateMines(layout);
        watch.stop();
        slowest = watch.elapsedMilliseconds > slowest ? watch.elapsedMilliseconds : slowest;

        final stuck = Solver(layout: layout, mines: mines, neighbours: neighbours).run();
        expect(mines.where((mine) => mine).length, difficulty.mines);
        expect(mines[layout.safeIndex], isFalse);
        expect(stuck, isNull, reason: "${difficulty.label} still needs a guess");
      }

      // ignore: avoid_print
      print("${difficulty.label}: slowest of 10 layouts $slowest ms");
    }
  });

  test("revealing floods from a zero and ends in a win once every safe cell is open", () {
    // One mine in the top-left corner: opening the opposite corner floods everything else.
    final mines = List.filled(Difficulty.easy.cellCount, false)..[0] = true;
    var board = Board.withMines(Difficulty.easy, mines);
    expect(board.cells[1].adjacentMines, 1);
    expect(board.cells[4].adjacentMines, 0);

    final move = board.reveal(Difficulty.easy.cellCount - 1);
    board = move.board;
    expect(board.status, GameStatus.won);
    expect(move.opened.length, Difficulty.easy.cellCount - 1);
    expect(board.cells[0].state, CellState.hidden);
    expect(board.minesLeft, 0);
  });

  test("a save file round-trips cells, flags and the exploded mine", () {
    // A wall of mines down column 4 keeps the flood on the left half.
    final mines = List.filled(Difficulty.easy.cellCount, false);
    for (var row = 0; row < Difficulty.easy.rows; row++) {
      mines[row * Difficulty.easy.columns + 4] = true;
    }
    var board = Board.withMines(Difficulty.easy, mines);
    board = board.reveal(0).board.toggleFlag(4).toggleFlag(8);
    expect(board.status, GameStatus.playing);
    expect(board.cells[3].isRevealed, isTrue);
    expect(board.cells[5].isHidden, isTrue);

    final decoded = Board.decode(Difficulty.easy, board.encode());
    expect(decoded.status, GameStatus.playing);
    expect(decoded.cells[4].isFlagged && decoded.cells[4].isMine, isTrue);
    expect(decoded.cells[8].isFlagged && !decoded.cells[8].isMine, isTrue);
    expect(
      decoded.cells.where((cell) => cell.isRevealed).length,
      board.cells.where((cell) => cell.isRevealed).length,
    );

    final lost = board.reveal(13).board;
    expect(lost.status, GameStatus.lost);
    expect(Board.decode(Difficulty.easy, lost.encode()).status, GameStatus.lost);
  });
}
