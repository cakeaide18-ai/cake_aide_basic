import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';

class SupplyRepository extends FirebaseRepository<Supply> {
  SupplyRepository()
      : super(
          collectionName: FirestoreCollections.supplies,
          fromMap: (map) => Supply.fromJson(map),
          toMap: (supply) => supply.toJson(),
        );

  // Get supplies with low stock (based on quantity threshold)
  Future<List<Supply>> getLowStockSupplies({double threshold = 5.0}) async {
    final allSupplies = await getAll();
    return allSupplies.where((supply) => supply.quantity <= threshold).toList();
  }
}
