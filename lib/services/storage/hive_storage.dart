// Flutter packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';

/// The one local box. `main` opens it before the first read, and it is a regular box (not lazy)
/// so the controllers can read their defaults synchronously in `build()`.
class HiveStorage {
  static const boxName = "codesweeper";

  final Box hiveBox = Hive.box(boxName);

  String? read(String key) => hiveBox.get(key) as String?;

  Future<bool> save(String key, String value) async {
    try {
      await hiveBox.put(key, value);
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> deleteKey(String key) async => await hiveBox.delete(key);
}

final hiveStorageProvider = Provider<HiveStorage>((ref) => HiveStorage());
