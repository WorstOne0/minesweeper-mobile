// Dart
import 'dart:convert';

// Flutter packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Models
import '/core/models/best_time.dart';
import '/core/models/difficulty.dart';
// Services
import '/services/storage/hive_storage.dart';

/// One saved game and one top-five list per difficulty, each a JSON string in Hive.
class GameRepository {
  const GameRepository({required this.storage});

  final HiveStorage storage;

  ({String cells, int seconds})? savedGame(Difficulty difficulty) {
    final raw = storage.read("game_${difficulty.name}");
    if (raw == null) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    return (cells: "${json["cells"]}", seconds: (json["seconds"] as num?)?.toInt() ?? 0);
  }

  Future<void> saveGame(Difficulty difficulty, String cells, int seconds) =>
      storage.save("game_${difficulty.name}", jsonEncode({"cells": cells, "seconds": seconds}));

  Future<void> clearGame(Difficulty difficulty) => storage.deleteKey("game_${difficulty.name}");

  List<BestTime> bestTimes(Difficulty difficulty) {
    final raw = storage.read("best_times_${difficulty.name}");
    if (raw == null) return const [];

    return [
      for (final data in jsonDecode(raw) as List)
        BestTime.fromJson(Map<String, dynamic>.from(data)),
    ];
  }

  Future<void> saveBestTimes(Difficulty difficulty, List<BestTime> times) => storage.save(
    "best_times_${difficulty.name}",
    jsonEncode([for (final time in times) time.toJson()]),
  );
}

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepository(storage: ref.watch(hiveStorageProvider));
});
