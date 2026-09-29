enum CellState { hidden, revealed, flagged }

class Cell {
  const Cell({this.isMine = false, this.adjacentMines = 0, this.state = CellState.hidden});

  final bool isMine;
  final int adjacentMines;
  final CellState state;

  bool get isHidden => state == CellState.hidden;
  bool get isRevealed => state == CellState.revealed;
  bool get isFlagged => state == CellState.flagged;

  Cell copyWith({bool? isMine, int? adjacentMines, CellState? state}) => Cell(
    isMine: isMine ?? this.isMine,
    adjacentMines: adjacentMines ?? this.adjacentMines,
    state: state ?? this.state,
  );
}
