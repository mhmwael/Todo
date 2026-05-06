enum TaskFrequency {
  none(
    'All',
  ),
  daily(
    'Daily',
  ),
  weekly(
    'Weekly',
  ),
  monthly(
    'Monthly',
  );

  final String
  displayName;
  const TaskFrequency(
    this.displayName,
  );

  static TaskFrequency
  fromString(
    String value,
  ) {
    return TaskFrequency.values.firstWhere(
      (
        freq,
      ) =>
          freq.name ==
          value,
      orElse: () => TaskFrequency.none,
    );
  }
}
