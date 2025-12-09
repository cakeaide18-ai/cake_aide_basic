import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/quote.dart';
import 'package:cake_aide_basic/services/data_service.dart';

void main() {
  group('Quote cost calculations', () {
    test('margin and total cost math is consistent', () {
      final data = DataService();
      // Use an existing recipe from DataService to ensure ingredients exist
      final recipe = data.recipes.first;

      final quoteRecipe = QuoteRecipe(recipe: recipe, quantity: 1.0);
      final quote = Quote(
        id: 't1',
        name: 'Test Quote',
        description: 'desc',
        recipes: [quoteRecipe],
        supplies: [],
        timeRequired: 1.0,
        marginPercentage: 10.0,
        deliveryCost: 5.0,
        imagePath: null,
        createdAt: DateTime.now(),
      );

      final baseCost = quote.baseCost;
      final marginAmount = quote.marginAmount;
      final totalCost = quote.totalCost;

      expect(marginAmount, closeTo(baseCost * 0.10, 0.0001));
      expect(totalCost, closeTo(baseCost + marginAmount + 5.0, 0.0001));
    });
  });
}
