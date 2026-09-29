// Dart
import 'dart:math';

// Models
import '/core/models/board.dart';

typedef MineLayout = ({int rows, int columns, int mines, int safeIndex});

const maxRepairs = 400;
const maxRestarts = 8;

/// Lays the mines so a player starting at [safeIndex] never has to guess: a solver plays the
/// board and, each time it is stuck, one mine on its frontier moves into the unknown interior.
/// Pure and top-level so `compute` can run it in an isolate; gives up on a plain random board
/// after [maxRestarts] layouts, which only happens on the densest boards.
List<bool> generateMines(MineLayout layout) {
  final random = Random();
  final total = layout.rows * layout.columns;
  final neighbours = [
    for (var index = 0; index < total; index++)
      Board.neighboursOf(index, layout.rows, layout.columns),
  ];
  final safeZone = {layout.safeIndex, ...neighbours[layout.safeIndex]};

  List<bool> randomLayout() {
    final mines = List.filled(total, false);
    final free = [
      for (var index = 0; index < total; index++)
        if (!safeZone.contains(index)) index,
    ]..shuffle(random);
    for (final index in free.take(layout.mines)) {
      mines[index] = true;
    }
    return mines;
  }

  var mines = randomLayout();
  var repairs = 0, restarts = 0;

  while (true) {
    final stuck = Solver(layout: layout, mines: mines, neighbours: neighbours).run();
    if (stuck == null) return mines;

    final frontierMines = stuck.frontier.where((index) => mines[index]).toList();
    final room = stuck.interior.where((index) => !mines[index]).toList();

    if (frontierMines.isEmpty || room.isEmpty || repairs >= maxRepairs) {
      if (restarts >= maxRestarts) return mines;

      mines = randomLayout();
      repairs = 0;
      restarts++;
      continue;
    }

    mines[frontierMines[random.nextInt(frontierMines.length)]] = false;
    mines[room[random.nextInt(room.length)]] = true;
    repairs++;
  }
}

/// Plays a layout with the three deductions a careful player makes: a number's remaining mines
/// fill or clear its unknown neighbours, one number's unknowns being a subset of another's,
/// and the global mine count.
class Solver {
  Solver({required this.layout, required this.mines, required this.neighbours})
    : total = layout.rows * layout.columns {
    numbers = List.generate(total, (index) {
      if (mines[index]) return -1;
      return neighbours[index].where((neighbour) => mines[neighbour]).length;
    });
    revealed = List.filled(total, false);
    flagged = List.filled(total, false);
    queued = List.filled(total, false);
  }

  final MineLayout layout;
  final List<bool> mines;
  final List<List<int>> neighbours;
  final int total;

  late final List<int> numbers;
  late final List<bool> revealed, flagged, queued;
  final queue = <int>[];
  var revealedCount = 0, flaggedCount = 0;

  /// Null once every safe cell is open; otherwise the unknown cells next to the open area and
  /// the unknown cells beyond them, for the generator to repair.
  ({List<int> frontier, List<int> interior})? run() {
    open(layout.safeIndex);

    while (true) {
      if (revealedCount == total - layout.mines) return null;
      if (drainQueue() || subsetPass() || globalPass()) continue;

      final unknown = [
        for (var index = 0; index < total; index++)
          if (!revealed[index] && !flagged[index]) index,
      ];
      final frontier = unknown.where((index) => neighbours[index].any((n) => revealed[n])).toSet();

      return (
        frontier: frontier.toList(),
        interior: unknown.where((index) => !frontier.contains(index)).toList(),
      );
    }
  }

  void open(int start) {
    final stack = [start];
    while (stack.isNotEmpty) {
      final index = stack.removeLast();
      if (revealed[index]) continue;

      revealed[index] = true;
      revealedCount++;
      enqueue(index);
      for (final neighbour in neighbours[index]) {
        if (revealed[neighbour]) enqueue(neighbour);
        if (numbers[index] == 0) stack.add(neighbour);
      }
    }
  }

  void flag(int index) {
    flagged[index] = true;
    flaggedCount++;
    for (final neighbour in neighbours[index]) {
      if (revealed[neighbour]) enqueue(neighbour);
    }
  }

  void enqueue(int index) {
    if (numbers[index] <= 0 || queued[index]) return;

    queued[index] = true;
    queue.add(index);
  }

  List<int> unknownAround(int index) => [
    for (final n in neighbours[index])
      if (!revealed[n] && !flagged[n]) n,
  ];

  int minesLeft(int index) => numbers[index] - neighbours[index].where((n) => flagged[n]).length;

  bool drainQueue() {
    var progress = false;

    while (queue.isNotEmpty) {
      final index = queue.removeLast();
      queued[index] = false;

      final unknown = unknownAround(index);
      if (unknown.isEmpty) continue;

      final left = minesLeft(index);
      if (left == 0) unknown.forEach(open);
      if (left == unknown.length) unknown.forEach(flag);
      if (left == 0 || left == unknown.length) progress = true;
    }

    return progress;
  }

  bool subsetPass() {
    final frontier = <int, List<int>>{};
    for (var index = 0; index < total; index++) {
      if (!revealed[index] || numbers[index] <= 0) continue;

      final unknown = unknownAround(index);
      if (unknown.isNotEmpty) frontier[index] = unknown;
    }

    for (final MapEntry(key: a, value: unknownA) in frontier.entries) {
      final row = a ~/ layout.columns, column = a % layout.columns;
      final leftA = minesLeft(a);

      for (var rowOffset = -2; rowOffset <= 2; rowOffset++) {
        for (var columnOffset = -2; columnOffset <= 2; columnOffset++) {
          final r = row + rowOffset, c = column + columnOffset;
          if (r < 0 || r >= layout.rows || c < 0 || c >= layout.columns) continue;

          final b = r * layout.columns + c;
          final unknownB = frontier[b];
          if (b == a || unknownB == null || unknownB.length <= unknownA.length) continue;
          if (!unknownA.every(unknownB.contains)) continue;

          final rest = unknownB.where((index) => !unknownA.contains(index)).toList();
          final restMines = minesLeft(b) - leftA;
          if (restMines == 0) {
            rest.forEach(open);
            return true;
          }
          if (restMines == rest.length) {
            rest.forEach(flag);
            return true;
          }
        }
      }
    }

    return false;
  }

  bool globalPass() {
    final unknown = [
      for (var index = 0; index < total; index++)
        if (!revealed[index] && !flagged[index]) index,
    ];
    final left = layout.mines - flaggedCount;
    if (unknown.isEmpty) return false;

    if (left == 0) unknown.forEach(open);
    if (left == unknown.length) unknown.forEach(flag);

    return left == 0 || left == unknown.length;
  }
}
