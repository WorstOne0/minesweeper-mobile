// Dart
import 'dart:math';

// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';

// Models
import '/core/models/board.dart';
// Utils
import '/utils/extensions/context_extensions.dart';

/// The board, painted as one piece so hidden cells merge into one rounded slab and neighbouring
/// flags into one block. Fits the space it is given; pinch to zoom on the bigger boards.
class BoardView extends StatefulWidget {
  const BoardView({
    required this.board,
    required this.lastMove,
    required this.longPress,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final Board board;
  final ({int origin, List<int> opened})? lastMove;
  final Duration longPress;
  final ValueChanged<int> onTap, onLongPress;

  @override
  State<BoardView> createState() => BoardViewState();
}

class BoardViewState extends State<BoardView> with TickerProviderStateMixin {
  late final AnimationController revealController = AnimationController(vsync: this);
  late final AnimationController flagController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  /// Cells shrinking out of the slab, each with the point of the cascade (0..1) it starts at.
  Map<int, double> revealing = {};
  double revealWindow = 1;
  Set<int> flagging = {};

  static const ringDelayMs = 35, shrinkMs = 220;

  @override
  void dispose() {
    revealController.dispose();
    flagController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final board = widget.board;
    if (identical(board, oldWidget.board)) return;
    if (board.cells.length != oldWidget.board.cells.length || board.status == GameStatus.fresh) {
      revealing = {};
      flagging = {};
      return;
    }

    final opened = <int>[], flagged = <int>[];
    for (final (index, cell) in board.cells.indexed) {
      final before = oldWidget.board.cells[index];
      if (cell.isRevealed && !before.isRevealed && !cell.isMine) opened.add(index);
      if (cell.isFlagged && !before.isFlagged) flagged.add(index);
    }
    if (opened.isNotEmpty) startReveal(opened);
    if (flagged.isNotEmpty) startFlag(flagged);
  }

  // Animations
  void startReveal(List<int> opened) {
    final board = widget.board;
    final origin = widget.lastMove?.origin ?? opened.first;
    final originRow = board.rowOf(origin), originColumn = board.columnOf(origin);

    final rings = <int, int>{};
    var farthest = 0;
    for (final index in opened) {
      final ring = max(
        (board.rowOf(index) - originRow).abs(),
        (board.columnOf(index) - originColumn).abs(),
      );
      rings[index] = ring;
      farthest = max(farthest, ring);
    }

    final total = shrinkMs + ringDelayMs * farthest;
    revealing = {for (final entry in rings.entries) entry.key: ringDelayMs * entry.value / total};
    revealWindow = shrinkMs / total;
    revealController.duration = Duration(milliseconds: total);
    revealController.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => revealing = {});
    });
  }

  void startFlag(List<int> flagged) {
    flagging = {...flagging, ...flagged};
    flagController.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => flagging = {});
    });
  }

  int cellAt(Offset position, double cellSize) {
    final board = widget.board;
    final column = (position.dx / cellSize).floor().clamp(0, board.columns - 1);
    final row = (position.dy / cellSize).floor().clamp(0, board.rows - 1);

    return board.indexOf(row, column);
  }

  @override
  Widget build(BuildContext context) {
    final board = widget.board;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = min(
          constraints.maxWidth / board.columns,
          constraints.maxHeight / board.rows,
        );
        final size = Size(cellSize * board.columns, cellSize * board.rows);

        return Center(
          child: SizedBox.fromSize(
            size: size,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: RawGestureDetector(
                behavior: .opaque,
                gestures: {
                  TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    TapGestureRecognizer.new,
                    (recognizer) =>
                        recognizer.onTapUp = (details) =>
                            widget.onTap(cellAt(details.localPosition, cellSize)),
                  ),
                  LongPressGestureRecognizer:
                      GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
                        () => LongPressGestureRecognizer(duration: widget.longPress),
                        (recognizer) =>
                            recognizer.onLongPressStart = (details) =>
                                widget.onLongPress(cellAt(details.localPosition, cellSize)),
                      ),
                },
                child: CustomPaint(
                  size: size,
                  painter: BoardPainter(
                    board: board,
                    cellSize: cellSize,
                    colors: context.colorScheme,
                    textStyle: context.textTheme.bodyMedium ?? const TextStyle(),
                    revealing: revealing,
                    revealWindow: revealWindow,
                    reveal: revealController,
                    flagging: flagging,
                    flagPop: flagController,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.cellSize,
    required this.colors,
    required this.textStyle,
    required this.revealing,
    required this.revealWindow,
    required this.reveal,
    required this.flagging,
    required this.flagPop,
  }) : super(repaint: Listenable.merge([reveal, flagPop]));

  final Board board;
  final double cellSize;
  final ColorScheme colors;
  final TextStyle textStyle;
  final Map<int, double> revealing;
  final double revealWindow;
  final Animation<double> reveal;
  final Set<int> flagging;
  final Animation<double> flagPop;

  late final double radius = cellSize * 0.22;
  late final double flagInset = cellSize * 0.08;
  late final double dashInset = cellSize * 0.24;

  late final List<TextPainter?> numbers = List.generate(9, (number) {
    if (number == 0) return null;
    return TextPainter(
      text: TextSpan(
        text: "$number",
        style: textStyle.copyWith(
          fontSize: cellSize * 0.5,
          fontWeight: .w500,
          color: colors.onSurfaceVariant,
        ),
      ),
      textDirection: .ltr,
    )..layout();
  });

  Offset cellCenter(int index) => Offset(
    (board.columnOf(index) + 0.5) * cellSize,
    (board.rowOf(index) + 0.5) * cellSize,
  );

  TextPainter glyph(IconData icon, Color color, {double scale = 0.55}) => TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: cellSize * scale,
        color: color,
      ),
    ),
    textDirection: .ltr,
  )..layout();

  void paintGlyph(Canvas canvas, TextPainter glyph, Offset center) =>
      glyph.paint(canvas, center - Offset(glyph.width / 2, glyph.height / 2));

  @override
  void paint(Canvas canvas, Size size) {
    final won = board.status == GameStatus.won, lost = board.status == GameStatus.lost;

    // What each cell is right now, animation included: the slab is every cell still hidden,
    // the blocks every flag (and every mine once the game is won).
    final slab = <int>{}, blocks = <int>{};
    for (final (index, cell) in board.cells.indexed) {
      final start = revealing[index];
      if (start != null && reveal.value >= start) continue;
      if (start != null || (cell.isHidden && !(won && cell.isMine))) slab.add(index);
      if ((cell.isFlagged && !flagging.contains(index)) || (won && cell.isMine)) blocks.add(index);
    }

    paintGrid(canvas, slab);
    paintNumbers(canvas);
    paintRegion(canvas, slab, colors.primary, inset: 0);
    paintRegion(canvas, blocks, colors.secondaryContainer, inset: flagInset);
    paintGlyphs(canvas, blocks, lost: lost);
    paintRevealing(canvas);
    paintFlagging(canvas);
  }

  /// Short dashes on the edges between two open cells, inset so the corners stay clear.
  void paintGrid(Canvas canvas, Set<int> slab) {
    final paint = Paint()
      ..color = colors.outlineVariant
      ..strokeWidth = 1;

    for (var row = 0; row < board.rows; row++) {
      for (var column = 0; column < board.columns; column++) {
        final index = board.indexOf(row, column);
        if (slab.contains(index)) continue;

        final x = column * cellSize, y = row * cellSize;
        if (column + 1 < board.columns && !slab.contains(index + 1)) {
          canvas.drawLine(
            Offset(x + cellSize, y + dashInset),
            Offset(x + cellSize, y + cellSize - dashInset),
            paint,
          );
        }
        if (row + 1 < board.rows && !slab.contains(index + board.columns)) {
          canvas.drawLine(
            Offset(x + dashInset, y + cellSize),
            Offset(x + cellSize - dashInset, y + cellSize),
            paint,
          );
        }
      }
    }
  }

  void paintNumbers(Canvas canvas) {
    for (final (index, cell) in board.cells.indexed) {
      if (!cell.isRevealed || cell.isMine || cell.adjacentMines == 0) continue;

      paintGlyph(canvas, numbers[cell.adjacentMines]!, cellCenter(index));
    }
  }

  /// Every cell of [region] as one shape: outer corners rounded, shared edges seamless, and the
  /// notch at an inner corner filled with a fillet so it rounds the other way.
  void paintRegion(Canvas canvas, Set<int> region, Color color, {required double inset}) {
    if (region.isEmpty) return;

    final paint = Paint()..color = color;
    final page = Paint()..color = colors.surface;
    final corner = Radius.circular(radius);

    bool has(int row, int column) =>
        row >= 0 &&
        row < board.rows &&
        column >= 0 &&
        column < board.columns &&
        region.contains(board.indexOf(row, column));

    for (final index in region) {
      final row = board.rowOf(index), column = board.columnOf(index);
      final up = has(row - 1, column), down = has(row + 1, column);
      final left = has(row, column - 1), right = has(row, column + 1);
      final x = column * cellSize, y = row * cellSize;

      final rect = Rect.fromLTRB(
        x + (left ? 0 : inset),
        y + (up ? 0 : inset),
        x + cellSize - (right ? 0 : inset),
        y + cellSize - (down ? 0 : inset),
      );
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: up || left ? Radius.zero : corner,
          topRight: up || right ? Radius.zero : corner,
          bottomLeft: down || left ? Radius.zero : corner,
          bottomRight: down || right ? Radius.zero : corner,
        ),
        paint,
      );

      // Inner corners: the neighbours on both sides sit inset from the diagonal cell, so the
      // cell's own corner is trimmed back to meet them, then the notch gets its fillet.
      final notches = [
        if (up && left && !has(row - 1, column - 1)) (Offset(x, y), -1, -1),
        if (up && right && !has(row - 1, column + 1)) (Offset(x + cellSize, y), 1, -1),
        if (down && left && !has(row + 1, column - 1)) (Offset(x, y + cellSize), -1, 1),
        if (down && right && !has(row + 1, column + 1)) (Offset(x + cellSize, y + cellSize), 1, 1),
      ];
      for (final (point, dx, dy) in notches) {
        final trimmed = point.translate(-dx * inset, -dy * inset);
        if (inset > 0) canvas.drawRect(Rect.fromPoints(point, trimmed), page);
        paintFillet(canvas, trimmed, dx, dy, paint);
      }
    }
  }

  /// The sliver between an inner corner and a quarter circle bulging towards it.
  void paintFillet(Canvas canvas, Offset corner, int dx, int dy, Paint paint) {
    final center = corner.translate(dx * radius, dy * radius);
    final a = Offset(corner.dx, corner.dy + dy * radius);
    final b = Offset(corner.dx + dx * radius, corner.dy);
    final startAngle = atan2(a.dy - center.dy, a.dx - center.dx);
    var sweep = atan2(b.dy - center.dy, b.dx - center.dx) - startAngle;
    if (sweep > pi) sweep -= 2 * pi;
    if (sweep < -pi) sweep += 2 * pi;

    final path = Path()
      ..moveTo(corner.dx, corner.dy)
      ..lineTo(a.dx, a.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), startAngle, sweep, false)
      ..close();
    canvas.drawPath(path, paint);
  }

  void paintGlyphs(Canvas canvas, Set<int> blocks, {required bool lost}) {
    final flag = glyph(Icons.flag, colors.onSecondaryContainer);
    final wrongFlag = glyph(Icons.flag, colors.error);
    for (final index in blocks) {
      final cell = board.cells[index];
      paintGlyph(canvas, lost && !cell.isMine ? wrongFlag : flag, cellCenter(index));
    }
    if (!lost) return;

    final mine = glyph(Icons.bug_report, colors.onPrimary);
    final exploded = glyph(Icons.bug_report, colors.onError);
    final boom = Paint()..color = colors.error;
    for (final (index, cell) in board.cells.indexed) {
      if (!cell.isMine) continue;

      if (cell.isHidden) paintGlyph(canvas, mine, cellCenter(index));
      if (cell.isRevealed) {
        final rect = Rect.fromCenter(center: cellCenter(index), width: cellSize, height: cellSize);
        canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), boom);
        paintGlyph(canvas, exploded, cellCenter(index));
      }
    }
  }

  /// Opened cells leave the slab one ring at a time, each shrinking away as its turn comes.
  void paintRevealing(Canvas canvas) {
    final paint = Paint()..color = colors.primary;

    for (final MapEntry(key: index, value: start) in revealing.entries) {
      final t = ((reveal.value - start) / revealWindow).clamp(0.0, 1.0);
      final scale = 1 - Curves.easeInCubic.transform(t);
      if (scale <= 0) continue;

      final rect = Rect.fromCenter(
        center: cellCenter(index),
        width: cellSize * scale,
        height: cellSize * scale,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius * scale)), paint);
    }
  }

  /// A new flag pops in with a little overshoot before it joins its block.
  void paintFlagging(Canvas canvas) {
    if (flagging.isEmpty) return;

    final scale = Curves.easeOutBack.transform(flagPop.value);
    final paint = Paint()..color = colors.secondaryContainer;
    final flag = glyph(Icons.flag, colors.onSecondaryContainer);
    final half = cellSize / 2 - flagInset;

    for (final index in flagging) {
      final center = cellCenter(index);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTRB(-half, -half, half, half), Radius.circular(radius)),
        paint,
      );
      paintGlyph(canvas, flag, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) =>
      !identical(oldDelegate.board, board) ||
      oldDelegate.cellSize != cellSize ||
      oldDelegate.colors != colors ||
      oldDelegate.revealing != revealing ||
      oldDelegate.flagging != flagging;
}
