/// One finished game, stored as JSON in Hive under its difficulty. [id] is the finish instant
/// in ms, so a list can point at the entry the player just made.
class BestTime {
  const BestTime({required this.id, required this.seconds, required this.date});

  final int id, seconds;
  final DateTime date;

  Duration get duration => Duration(seconds: seconds);

  factory BestTime.fromJson(Map<String, dynamic> json) => BestTime(
    id: (json["id"] as num?)?.toInt() ?? 0,
    seconds: (json["seconds"] as num?)?.toInt() ?? 0,
    date: DateTime.tryParse("${json["date"]}") ?? DateTime.now(),
  );

  Map<String, dynamic> toJson() => {"id": id, "seconds": seconds, "date": date.toIso8601String()};
}
