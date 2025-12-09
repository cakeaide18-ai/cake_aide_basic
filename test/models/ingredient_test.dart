import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/ingredient.dart';

void main() {
  test('Ingredient JSON round-trip preserves fields', () {
    final original = Ingredient(
      id: 'ing_1',
      name: 'Sugar',
      brand: 'SweetCo',
      price: 2.5,
      unit: 'kg',
      currency: '£',
      quantity: 1.5,
    );

    final map = original.toMap();
    final restored = Ingredient.fromJson(map);

    expect(restored, equals(original));
    expect(restored.hashCode, equals(original.hashCode));
    expect(restored.toString().contains('Sugar'), isTrue);
  });

  group('Ingredient.fromJson', () {
    test('handles numeric and string numbers and nulls', () {
      final json1 = {
        'id': 'i1',
        'name': 'Flour',
        'brand': 'Brand',
        'price': 2.5,
        'unit': 'kg',
        'quantity': 1
      };
      final ing1 = Ingredient.fromJson(json1);
      expect(ing1.price, 2.5);
      expect(ing1.quantity, 1.0);

      final json2 = {
        'id': 'i2',
        'name': 'Sugar',
        'brand': 'Brand',
        'price': '3.75',
        'unit': 'kg',
        'quantity': '2'
      };
      final ing2 = Ingredient.fromJson(json2);
      expect(ing2.price, 3.75);
      expect(ing2.quantity, 2.0);

      final json3 = {'id': 'i3', 'name': 'Salt', 'brand': 'Brand', 'price': null, 'unit': 'g'};
      final ing3 = Ingredient.fromJson(json3);
      expect(ing3.price, 0.0);
      expect(ing3.quantity, 1.0); // default
    });
  });
}
