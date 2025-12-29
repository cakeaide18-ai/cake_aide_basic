import 'package:cake_aide_basic/models/quote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';

class QuoteRepository extends FirebaseRepository<Quote> {
  QuoteRepository() : super(
    collectionName: FirestoreCollections.quotes,
    fromMap: (map) => Quote.fromJson(map),
    toMap: (quote) => quote.toJson(),
  );

  // Get all quotes
  Future<List<Quote>> getAllQuotes() async {
    return await getAll();
  }

  // Get quotes stream for real-time updates
  Stream<List<Quote>> getQuotesStream() {
    return getStream();
  }
}
