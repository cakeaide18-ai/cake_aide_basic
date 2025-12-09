import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/quote.dart';

void main() {
  group('Quote.fromJson', () {
    test('parses numeric fields and collections safely', () {
      final json = {
        'id': 'q1',
        'name': 'Quote 1',
        'description': 'Desc',
        'recipes': [],
        'supplies': [],
        'timeRequired': '2.5',
        'marginPercentage': 10,
        'deliveryCost': null,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final q = Quote.fromJson(json);
      expect(q.timeRequired, 2.5);
      expect(q.marginPercentage, 10.0);
      expect(q.deliveryCost, 0.0);
    });
  });
}
