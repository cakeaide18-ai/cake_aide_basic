import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/supply.dart';

void main() {
  test('Supply JSON round-trip preserves fields', () {
    final original = Supply(
      id: 'sup_1',
      name: 'Cake Box',
      brand: 'BoxCo',
      price: 1.5,
      unit: 'pieces',
      currency: '£',
      quantity: 50,
    );

    final map = original.toMap();
    final restored = Supply.fromJson(map);

    expect(restored, equals(original));
    expect(restored.hashCode, equals(original.hashCode));
    expect(restored.toString().contains('Cake Box'), isTrue);
  });

  group('Supply.fromJson', () {
    test('handles numeric and string numbers and nulls', () {
      final json1 = {
        'id': 's1',
        'name': 'Ribbon',
        'brand': 'Brand',
        'price': 5.0,
        'unit': 'm',
        'quantity': 100
      };
      final sup1 = Supply.fromJson(json1);
      expect(sup1.price, 5.0);
      expect(sup1.quantity, 100.0);

      final json2 = {
        'id': 's2',
        'name': 'Dowel',
        'brand': 'Brand',
        'price': '0.5',
        'unit': 'pieces',
        'quantity': '200'
      };
      final sup2 = Supply.fromJson(json2);
      expect(sup2.price, 0.5);
      expect(sup2.quantity, 200.0);

      final json3 = {'id': 's3', 'name': 'Tape', 'brand': 'Brand', 'price': null, 'unit': 'roll'};
      final sup3 = Supply.fromJson(json3);
      expect(sup3.price, 0.0);
      expect(sup3.quantity, 0.0); // default
    });
  });
}
