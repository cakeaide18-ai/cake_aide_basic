import 'package:cake_aide_basic/repositories/firebase_repository.dart';
import 'package:cake_aide_basic/models/user_profile.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Repository for managing user profiles in Firestore
/// Note: User profiles use userId as document ID, not owner_id filtering
class UserProfileRepository extends FirebaseRepository<UserProfile> {
  UserProfileRepository()
      : super(
          collectionName: FirestoreCollections.userProfiles,
          fromMap: (map, id) => UserProfile.fromMap({...map, 'id': id}),
          toMap: (profile) => profile.toMap(),
        );

  /// Get user profile by user ID
  Future<UserProfile?> getByUserId(String userId) async {
    try {
      final doc = await collection.doc(userId).get();
      if (!doc.exists) return null;
      return fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Create or update user profile with specific user ID
  Future<void> setUserProfile(String userId, UserProfile profile) async {
    try {
      await collection.doc(userId).set(
        {
          ...toMap(profile),
          FirestoreFields.createdAt: FieldValue.serverTimestamp(),
          FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to set user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await collection.doc(userId).update({
        ...updates,
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Delete user profile
  Future<void> deleteProfile(String userId) async {
    try {
      await collection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
