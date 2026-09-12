class LevelState {
  const LevelState({
    required this.id,
    required this.stars,
    required this.unlocked,
    this.bestTime,
  });

  final int id;
  final int stars;
  final bool unlocked;
  final double? bestTime;

  static LevelState locked(int id) =>
      LevelState(id: id, stars: 0, unlocked: false);

  LevelState copyWith({
    int? stars,
    bool? unlocked,
    double? bestTime,
  }) {
    return LevelState(
      id: id,
      stars: stars ?? this.stars,
      unlocked: unlocked ?? this.unlocked,
      bestTime: bestTime ?? this.bestTime,
    );
  }
}
