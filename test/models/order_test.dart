import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/order.dart';

void main() {
  test('Order JSON round-trip preserves fields', () {
    final original = Order(
      id: 'ord_1',
      name: 'Birthday Cake',
      customerName: 'John Doe',
      status: OrderStatus.inProgress,
      deliveryDate: DateTime(2025, 12, 24),
      deliveryTime: const TimeOfDay(hour: 14, minute: 30),
      price: 50.0,
      createdAt: DateTime(2025, 12, 20),
      updatedAt: DateTime(2025, 12, 21),
    );

    final map = original.toMap();
    final restored = Order.fromJson(map);

    expect(restored, equals(original));
    expect(restored.hashCode, equals(original.hashCode));
    expect(restored.toString().contains('Birthday Cake'), isTrue);
  });
}
