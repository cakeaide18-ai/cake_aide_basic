import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';
import 'package:cake_aide_basic/firestore/firestore_data_schema.dart';

class RecipeRepository extends FirebaseRepository<Recipe> {
  RecipeRepository() : super(
    collectionName: FirestoreCollections.recipes,
    fromMap: (map) => Recipe.fromJson(map),
    toMap: (recipe) => recipe.toJson(),
  );

  // Get recipes ordered by name
  Future<List<Recipe>> getRecipesOrderedByName() async {
    return await getAll();
  }

  // Get recipes by difficulty
  Future<List<Recipe>> getRecipesByDifficulty(String difficulty) async {
    final queryRef = query().where(FirestoreFields.difficulty, isEqualTo: difficulty);
    return await getWithQuery(queryRef);
  }
  
  // Get recipes by tags
  Future<List<Recipe>> getRecipesByTag(String tag) async {
    final queryRef = query().where(FirestoreFields.tags, arrayContains: tag);
    return await getWithQuery(queryRef);
  }
  
  // Get recipes stream
  Stream<List<Recipe>> getRecipesStream() {
    return getStream();
  }

  // Additional recipe-specific methods can be added here
}