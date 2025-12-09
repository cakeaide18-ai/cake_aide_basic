import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/shopping_list.dart';
import 'package:cake_aide_basic/models/ingredient.dart';

void main() {
  group('ShoppingList deep serialization', () {
    test('toJson/fromJson roundtrip preserves quantities and flags', () {
      final ingredient = Ingredient(
        id: 'ing1',
        name: 'Sugar',
        brand: 'Brand',
        price: 2.5,
        unit: 'kg',
        quantity: 1.0,
      );

      final sli = ShoppingListIngredient(ingredient: ingredient, quantity: 2.0, isChecked: true);
      final sl = ShoppingList(
        id: 'sl-test',
        name: 'My List',
        ingredients: [sli],
      );

      final json = sl.toJson();
      final parsed = ShoppingList.fromJson(json);

      expect(parsed.ingredients.length, 1);
      expect(parsed.ingredients.first.quantity, 2.0);
      expect(parsed.ingredients.first.isChecked, true);
      expect(parsed.name, 'My List');
    });
  });
}
