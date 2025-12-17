import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';

class ShoppingListRepository extends FirebaseRepository<ShoppingList> {
  ShoppingListRepository()
      : super(
          collectionName: FirestoreCollections.shoppingLists,
          fromFirestore: (data, id) => ShoppingList.fromFirestore(data, id: id),
          toFirestore: (list) => list.toMap(),
        );
}
