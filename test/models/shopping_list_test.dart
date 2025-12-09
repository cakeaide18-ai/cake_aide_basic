import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/models/ingredient.dart';

void main() {
  test('ShoppingList JSON round-trip preserves fields', () {
    final original = ShoppingList(
      id: 'sl_1',
      name: 'Christmas Shopping',
      recipes: [
        ShoppingListRecipe(
          recipe: Recipe(
            id: 'rec_1',
            name: 'Fruit Cake',
            cakeSizePortions: '10 inch square',
            ingredients: [],
          ),
          quantity: 1,
        ),
      ],
      supplies: [
        ShoppingListSupply(
          supply: Supply(
            id: 'sup_1',
            name: 'Cake Board',
            price: 2.0,
            unit: 'pieces',
            quantity: 1,
          ),
          quantity: 1,
        ),
      ],
      ingredients: [
        ShoppingListIngredient(
          ingredient: Ingredient(
            id: 'ing_1',
            name: 'Marzipan',
            price: 5.0,
            unit: 'kg',
            quantity: 1,
          ),
          quantity: 1,
        ),
      ],
    );

    final map = original.toMap();
    final restored = ShoppingList.fromJson(map);

    expect(restored, equals(original));
    expect(restored.hashCode, equals(original.hashCode));
    expect(restored.toString().contains('Christmas Shopping'), isTrue);
  });
}
