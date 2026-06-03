class WorkoutHistoryEntry {
  const WorkoutHistoryEntry({
    required this.id,
    required this.workoutId,
    required this.workoutTitle,
    required this.durationMinutes,
    required this.completedAt,
  });

  final String id;
  final String workoutId;
  final String workoutTitle;
  final int durationMinutes;
  final DateTime completedAt;

  factory WorkoutHistoryEntry.fromMap(String id, Map<String, dynamic> map) {
    return WorkoutHistoryEntry(
      id: id,
      workoutId: map['workoutId'] as String? ?? '',
      workoutTitle: map['workoutTitle'] as String? ?? 'Workout',
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 0,
      completedAt: DateTime.tryParse(map['completedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
      'durationMinutes': durationMinutes,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
