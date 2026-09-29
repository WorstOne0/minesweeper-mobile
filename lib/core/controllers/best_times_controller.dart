// Flutter packages
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
import '/core/models/best_time.dart';
import '/core/models/difficulty.dart';
// Repositories
import '/core/repositories/game_repository.dart';

@immutable
class BestTimesState {
  const BestTimesState({required this.times});

  final Map<Difficulty, List<BestTime>> times;

  List<BestTime> of(Difficulty difficulty) => times[difficulty] ?? const [];

  BestTimesState copyWith({Map<Difficulty, List<BestTime>>? times}) =>
      BestTimesState(times: times ?? this.times);
}

class BestTimesController extends Notifier<BestTimesState> {
  static const keep = 5;

  late final GameRepository repository;

  @override
  BestTimesState build() {
    repository = ref.watch(gameRepositoryProvider);

    return BestTimesState(
      times: {
        for (final difficulty in Difficulty.values) difficulty: repository.bestTimes(difficulty),
      },
    );
  }

  /// Files a finished game under [id]; answers its 1-based rank when it made the top [keep].
  /// An equal time ranks below the one already there.
  int? record(Difficulty difficulty, Duration elapsed, {required int id}) {
    final entry = BestTime(id: id, seconds: elapsed.inSeconds, date: DateTime.now());
    final times = List<BestTime>.of(state.of(difficulty));
    final slot = times.indexWhere((time) => time.seconds > entry.seconds);
    times.insert(slot == -1 ? times.length : slot, entry);

    final kept = times.take(keep).toList();
    state = state.copyWith(times: {...state.times, difficulty: kept});
    repository.saveBestTimes(difficulty, kept);

    final rank = kept.indexWhere((time) => time.id == id);
    return rank == -1 ? null : rank + 1;
  }
}

final bestTimesProvider = NotifierProvider<BestTimesController, BestTimesState>(
  BestTimesController.new,
);
