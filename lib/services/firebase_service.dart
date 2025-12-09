import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';
import 'package:flutter/foundation.dart';
import 'package:cake_aide_basic/models/user_profile.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/models/order.dart' as order_model;
import 'package:cake_aide_basic/models/quote.dart';
import 'package:cake_aide_basic/models/timer_recording.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  /// Creates a support issue document for the current user
  /// Returns the created document ID
  static Future<String> addSupportIssue({
    required String category,
    required String message,
    String? appVersion,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final data = <String, dynamic>{
      FirestoreFields.ownerId: currentUserId,
      FirestoreFields.issueCategory: category,
      FirestoreFields.issueMessage: message,
      FirestoreFields.issueUserEmail: _auth.currentUser?.email,
      FirestoreFields.issueAppVersion: appVersion,
      FirestoreFields.issuePlatform: kIsWeb ? 'web' : 'mobile',
      FirestoreFields.issueStatus: 'open',
      FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };

    final docRef = await _firestore
        .collection(FirestoreCollections.supportIssues)
        .add(data);

    // Also enqueue an email via Firebase "Trigger Email" extension by writing to /mail
    // This requires the extension to be installed and configured in Firebase Console.
    try {
      final userEmail = _auth.currentUser?.email;
      final subject = 'CakeAide Pro Support: $category';
      final textBody = [
        'A new support issue was submitted.',
        '',
  'Issue ID: ${docRef.id}',
  'User ID: $currentUserId',
        if (userEmail != null) 'User Email: $userEmail',
        if (appVersion != null) 'App Version: $appVersion',
  'Platform: ${kIsWeb ? 'web' : 'mobile'}',
        'Category: $category',
        '',
        'Message:',
        message,
      ].join('\n');

      await _firestore.collection(FirestoreCollections.mail).add({
        'to': ['support@cakeaidepro.com'],
        if (userEmail != null) 'replyTo': userEmail,
        'message': {
          'subject': subject,
          'text': textBody,
        },
        'metadata': {
          'source': 'support_issues',
          'support_issue_id': docRef.id,
          'owner_id': currentUserId,
        }
      });
    } catch (_) {
      // Swallow errors from the mail queue so support issue creation still succeeds
    }

    return docRef.id;
  }

  // User Profile Operations
  static Future<void> saveUserProfile(UserProfile profile) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = profile.toJson();
    data[FirestoreFields.ownerId] = currentUserId;
    
    await _firestore
        .collection(FirestoreCollections.userProfiles)
        .doc(profile.id)
        .set(data);
  }

  static Future<UserProfile?> getUserProfile(String profileId) async {
    if (currentUserId == null) return null;
    
    final doc = await _firestore
        .collection(FirestoreCollections.userProfiles)
        .doc(profileId)
        .get();
    
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      if (data[FirestoreFields.ownerId] == currentUserId) {
        return UserProfile.fromJson(data);
      }
    }
    return null;
  }

  // Ingredients Operations
  static Future<String> addIngredient(Ingredient ingredient) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = ingredient.toJson();
    data[FirestoreFields.ownerId] = currentUserId;
    data[FirestoreFields.createdAt] = FieldValue.serverTimestamp();
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    
    final docRef = await _firestore
        .collection(FirestoreCollections.ingredients)
        .add(data);
    
    return docRef.id;
  }

  static Stream<List<Ingredient>> getIngredientsStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(FirestoreCollections.ingredients)
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy(FirestoreFields.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to data
          return Ingredient.fromJson(data);
        }).toList());
  }

  // Supplies Operations
  static Future<String> addSupply(Supply supply) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = supply.toJson();
    data[FirestoreFields.ownerId] = currentUserId;
    data[FirestoreFields.createdAt] = FieldValue.serverTimestamp();
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    
    final docRef = await _firestore
        .collection(FirestoreCollections.supplies)
        .add(data);
    
    return docRef.id;
  }

  static Stream<List<Supply>> getSuppliesStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(FirestoreCollections.supplies)
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy(FirestoreFields.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to data
          return Supply.fromJson(data);
        }).toList());
  }

  // Recipes Operations
  static Future<String> addRecipe(Recipe recipe) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = recipe.toJson();
    data[FirestoreFields.ownerId] = currentUserId;
    data[FirestoreFields.createdAt] = FieldValue.serverTimestamp();
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    
    final docRef = await _firestore
        .collection(FirestoreCollections.recipes)
        .add(data);
    
    return docRef.id;
  }

  static Stream<List<Recipe>> getRecipesStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(FirestoreCollections.recipes)
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to data
          return Recipe.fromJson(data);
        }).toList());
  }

  // Orders Operations
  static Future<String> addOrder(order_model.Order order) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = order.toJson();
    data[FirestoreFields.ownerId] = currentUserId;
    
    final docRef = await _firestore
        .collection(FirestoreCollections.orders)
        .add(data);
    
    return docRef.id;
  }

  static Stream<List<order_model.Order>> getOrdersStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(FirestoreCollections.orders)
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy('deliveryDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to data
          return order_model.Order.fromJson(data);
        }).toList());
  }

  // Quotes Operations
  static Future<String> addQuote(Quote quote) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = quote.toJson();
    data[FirestoreFields.ownerId] = currentUserId;
    
    final docRef = await _firestore
        .collection(FirestoreCollections.quotes)
        .add(data);
    
    return docRef.id;
  }

  static Stream<List<Quote>> getQuotesStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(FirestoreCollections.quotes)
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to data
          return Quote.fromJson(data);
        }).toList());
  }

  // Shopping Lists Operations
  static Future<String> addShoppingList(ShoppingList shoppingList) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = shoppingList.toJson();
    data[FirestoreFields.ownerId] = currentUserId;
    
    final docRef = await _firestore
        .collection(FirestoreCollections.shoppingLists)
        .add(data);
    
    return docRef.id;
  }

  static Stream<List<ShoppingList>> getShoppingListsStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(FirestoreCollections.shoppingLists)
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to data
          return ShoppingList.fromJson(data);
        }).toList());
  }

  // Timer Recordings Operations
  static Future<String> addTimerRecording(TimerRecording recording) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = recording.toJson();
    data[FirestoreFields.ownerId] = currentUserId;
    
    final docRef = await _firestore
        .collection(FirestoreCollections.timerRecordings)
        .add(data);
    
    return docRef.id;
  }

  static Stream<List<TimerRecording>> getTimerRecordingsStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return _firestore
        .collection(FirestoreCollections.timerRecordings)
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy('startTime', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Add document ID to data
          return TimerRecording.fromJson(data);
        }).toList());
  }

  // Update operations
  static Future<void> updateIngredient(String id, Map<String, dynamic> updates) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    updates[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    await _firestore.collection(FirestoreCollections.ingredients).doc(id).update(updates);
  }

  static Future<void> updateSupply(String id, Map<String, dynamic> updates) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    updates[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    await _firestore.collection(FirestoreCollections.supplies).doc(id).update(updates);
  }

  static Future<void> updateRecipe(String id, Map<String, dynamic> updates) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    updates[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    await _firestore.collection(FirestoreCollections.recipes).doc(id).update(updates);
  }

  static Future<void> updateOrder(String id, Map<String, dynamic> updates) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    updates[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    await _firestore.collection(FirestoreCollections.orders).doc(id).update(updates);
  }

  // Delete operations
  static Future<void> deleteIngredient(String id) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    await _firestore.collection(FirestoreCollections.ingredients).doc(id).delete();
  }

  static Future<void> deleteSupply(String id) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    await _firestore.collection(FirestoreCollections.supplies).doc(id).delete();
  }

  static Future<void> deleteRecipe(String id) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    await _firestore.collection(FirestoreCollections.recipes).doc(id).delete();
  }

  static Future<void> deleteOrder(String id) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    await _firestore.collection(FirestoreCollections.orders).doc(id).delete();
  }

  static Future<void> deleteQuote(String id) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    await _firestore.collection(FirestoreCollections.quotes).doc(id).delete();
  }

  static Future<void> deleteShoppingList(String id) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    await _firestore.collection(FirestoreCollections.shoppingLists).doc(id).delete();
  }
}