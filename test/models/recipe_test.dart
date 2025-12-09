import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/ingredient.dart';

void main() {
  test('Recipe JSON round-trip preserves fields', () {
    final original = Recipe(
      id: 'rec_1',
      name: 'Chocolate Cake',
      cakeSizePortions: '8 inch round, 12 portions',
      ingredients: [
        RecipeIngredient(
          ingredient: Ingredient(
            id: 'ing_1',
            name: 'Flour',
            price: 1.0,
            unit: 'kg',
            quantity: 1.0,
          ),
          quantity: 250,
          unit: 'g',
        ),
      ],
    );

    final map = original.toMap();
    final restored = Recipe.fromJson(map);

    expect(restored, equals(original));
    expect(restored.hashCode, equals(original.hashCode));
    expect(restored.toString().contains('Chocolate Cake'), isTrue);
  });
}
