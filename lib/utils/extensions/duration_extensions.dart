extension DurationExtensions on Duration {
  /// The game clock: "38S", "3M 41S", "1H 2M 5S".
  String get clock {
    final hours = inHours;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;

    if (hours > 0) return "${hours}H ${minutes}M ${seconds}S";
    if (minutes > 0) return "${minutes}M ${seconds}S";
    return "${seconds}S";
  }
}
