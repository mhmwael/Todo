class UserStats {
  final int completedCount;
  final int totalCount;
  final int streak;

  const UserStats({
    required this.completedCount,
    required this.totalCount,
    required this.streak,
  });

  int get remainingCount => totalCount - completedCount;

  double get completionPercentage {
    if (totalCount == 0) return 0;
    return (completedCount / totalCount) * 100;
  }
}
