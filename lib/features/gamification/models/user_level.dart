class UserLevel {
  final int level;
  final String title;
  final int currentXp;
  final int nextLevelXp;

  const UserLevel({
    required this.level,
    required this.title,
    required this.currentXp,
    required this.nextLevelXp,
  });

  double get progressPercentage {
    if (nextLevelXp <= 0) return 1.0;
    return (currentXp / nextLevelXp).clamp(0.0, 1.0);
  }
}
