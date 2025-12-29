import 'package:cake_aide_basic/models/reminder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';

class ReminderRepository extends FirebaseRepository<Reminder> {
  ReminderRepository() : super(
    collectionName: FirestoreCollections.reminders,
    fromMap: (map) => Reminder.fromJson(map),
    toMap: (reminder) => reminder.toJson(),
  );

  // Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    return await getAll();
  }

  // Get reminders stream for real-time updates
  Stream<List<Reminder>> getRemindersStream() {
    return getStream();
  }

  // Get pending (not completed) reminders
  Future<List<Reminder>> getPendingReminders() async {
    final queryRef = query().where('isCompleted', isEqualTo: false);
    return await getWithQuery(queryRef);
  }

  // Get completed reminders
  Future<List<Reminder>> getCompletedReminders() async {
    final queryRef = query().where('isCompleted', isEqualTo: true);
    return await getWithQuery(queryRef);
  }

  // Toggle reminder completion status
  Future<void> toggleCompletion(String id, bool isCompleted) async {
    final reminder = await getById(id);
    if (reminder != null) {
      final updated = reminder.copyWith(
        isCompleted: !isCompleted,
        updatedAt: DateTime.now(),
      );
      await update(id, updated);
    }
  }
}
