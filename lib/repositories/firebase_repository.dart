import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';

/// Base repository class for Firebase Firestore operations
/// Provides common CRUD operations for all collections
abstract class FirebaseRepository<T> {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  
  final String collectionName;
  final T Function(Map<String, dynamic>) fromMap;
  final Map<String, dynamic> Function(T) toMap;
  
  FirebaseRepository({
    required this.collectionName,
    required this.fromMap,
    required this.toMap,
  });
  
  /// Get current user ID
  String? get currentUserId {
    try {
      // Avoid accessing FirebaseAuth when Firebase is not initialized (tests)
      if (Firebase.apps.isEmpty) return null;
      return _auth.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }
  
  /// Get collection reference
  CollectionReference<Map<String, dynamic>> get collection =>
      _firestore.collection(collectionName);
  
  /// Add a new document
  Future<String> add(T item) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = toMap(item);
    data[FirestoreFields.ownerId] = currentUserId;
    data[FirestoreFields.createdAt] = FieldValue.serverTimestamp();
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    
    final docRef = await collection.add(data);
    return docRef.id;
  }
  
  /// Update an existing document
  Future<void> update(String id, T item) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final data = toMap(item);
    data[FirestoreFields.updatedAt] = FieldValue.serverTimestamp();
    
    await collection.doc(id).update(data);
  }
  
  /// Delete a document
  Future<void> delete(String id) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await collection.doc(id).delete();
  }
  
  /// Get a single document by ID
  Future<T?> getById(String id) async {
    if (currentUserId == null) return null;
    
    final doc = await collection.doc(id).get();
    final data = doc.data();
    if (doc.exists && data != null) {
      final map = Map<String, dynamic>.from(data);
      if (map[FirestoreFields.ownerId] == currentUserId) {
        map[FirestoreFields.id] = doc.id;
        return fromMap(map);
      }
    }
    return null;
  }
  
  /// Get all documents for current user
  Future<List<T>> getAll() async {
    if (currentUserId == null) return [];
    
    final snapshot = await collection
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final map = Map<String, dynamic>.from(doc.data());
      map[FirestoreFields.id] = doc.id;
      return fromMap(map);
    }).toList();
  }
  
  /// Get documents stream for current user
  Stream<List<T>> getStream() {
    if (currentUserId == null) return Stream.value([]);
    
    return collection
        .where(FirestoreFields.ownerId, isEqualTo: currentUserId)
        .orderBy(FirestoreFields.createdAt, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final map = Map<String, dynamic>.from(doc.data());
          map[FirestoreFields.id] = doc.id;
          return fromMap(map);
        }).toList());
  }
  
  /// Query documents with custom conditions
  Query<Map<String, dynamic>> query() {
    return collection.where(FirestoreFields.ownerId, isEqualTo: currentUserId);
  }
  
  /// Get documents stream with custom query
  Stream<List<T>> getStreamWithQuery(Query<Map<String, dynamic>> query) {
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
      final map = Map<String, dynamic>.from(doc.data());
      map[FirestoreFields.id] = doc.id;
      return fromMap(map);
    }).toList());
  }
  
  /// Get documents with custom query
  Future<List<T>> getWithQuery(Query<Map<String, dynamic>> query) async {
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final map = Map<String, dynamic>.from(doc.data());
      map[FirestoreFields.id] = doc.id;
      return fromMap(map);
    }).toList();
  }
  
  /// Batch operations
  WriteBatch batch() => _firestore.batch();
  
  /// Execute batch
  Future<void> commitBatch(WriteBatch batch) async {
    await batch.commit();
  }
}