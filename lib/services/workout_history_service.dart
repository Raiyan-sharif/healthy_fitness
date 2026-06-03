import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthy_fitness/models/workout.dart';
import 'package:healthy_fitness/models/workout_history_entry.dart';

class WorkoutHistoryService {
  WorkoutHistoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _history(String uid) {
    return _firestore.collection('users').doc(uid).collection('workoutHistory');
  }

  Stream<List<WorkoutHistoryEntry>> watchHistory(String uid) {
    return _history(uid)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map(
            (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                WorkoutHistoryEntry.fromMap(doc.id, doc.data()),
          )
          .toList();
    });
  }

  Future<void> addCompletedWorkout({
    required String uid,
    required Workout workout,
  }) async {
    final WorkoutHistoryEntry entry = WorkoutHistoryEntry(
      id: '',
      workoutId: workout.id,
      workoutTitle: workout.title,
      durationMinutes: workout.durationMinutes,
      completedAt: DateTime.now(),
    );
    await _history(uid).add(entry.toMap());
  }
}
