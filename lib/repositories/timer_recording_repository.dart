import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';
import 'package:cake_aide_basic/models/timer_recording.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';

class TimerRecordingRepository extends FirebaseRepository<TimerRecording> {
  TimerRecordingRepository()
      : super(
          collectionName: FirestoreCollections.timerRecordings,
          fromFirestore: (data, id) => TimerRecording.fromFirestore(data, id: id),
          toFirestore: (recording) => recording.toMap(),
        );

  /// Get timer recordings ordered by start time (most recent first)
  Future<List<TimerRecording>> getRecent({int limit = 10}) async {
    final query = this.query().orderBy('startTime', descending: true).limit(limit);
    return getWithQuery(query);
  }

  /// Get timer recordings for a specific activity
  Future<List<TimerRecording>> getByActivity(String activity) async {
    final query = this.query().where('activity', isEqualTo: activity);
    return getWithQuery(query);
  }
}
