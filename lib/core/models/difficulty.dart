/// One row per level. Boards are portrait, so rows always exceed columns.
enum Difficulty {
  easy("Easy", 9, 12, 12),
  medium("Medium", 11, 18, 32),
  hard("Hard", 14, 24, 60),
  expert("Expert", 18, 30, 100),
  extreme("Extreme", 24, 40, 190);

  const Difficulty(this.label, this.columns, this.rows, this.mines);

  final String label;
  final int columns, rows, mines;

  int get cellCount => rows * columns;

  Difficulty get previous => values[(index - 1 + values.length) % values.length];
  Difficulty get next => values[(index + 1) % values.length];

  static Difficulty of(String? value) =>
      values.firstWhere((difficulty) => difficulty.name == value, orElse: () => easy);
}
