import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';

class IngredientRepository extends FirebaseRepository<Ingredient> {
  IngredientRepository()
      : super(
          collectionName: FirestoreCollections.ingredients,
          fromMap: (map) => Ingredient.fromJson(map),
          toMap: (ingredient) => ingredient.toJson(),
        );

  // Get ingredients with low stock (based on quantity threshold)
  Future<List<Ingredient>> getLowStockIngredients({double threshold = 10.0}) async {
    final allIngredients = await getAll();
    return allIngredients.where((ingredient) => 
        ingredient.quantity <= threshold).toList();
  }
}