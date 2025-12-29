import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';
import 'package:cake_aide_basic/services/settings_service.dart';
import 'package:cake_aide_basic/services/data_service.dart';

class QuoteSupply {
  final Supply supply;
  final double quantity;

  QuoteSupply({
    required this.supply,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'supply': supply.toJson(),
    'quantity': quantity,
  };

  factory QuoteSupply.fromJson(Map<String, dynamic> json) => QuoteSupply(
    supply: Supply.fromJson(json['supply']),
    quantity: parseDouble(json['quantity']),
  );
}

class QuoteRecipe {
  final Recipe recipe;
  final double quantity;

  QuoteRecipe({
    required this.recipe,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'recipe': recipe.toJson(),
    'quantity': quantity,
  };

  factory QuoteRecipe.fromJson(Map<String, dynamic> json) => QuoteRecipe(
    recipe: Recipe.fromJson(json['recipe']),
    quantity: parseDouble(json['quantity']),
  );
}

class Quote {
  final String id;
  final String name;
  final String description;
  final List<QuoteRecipe> recipes;
  final List<QuoteSupply> supplies;
  final double timeRequired; // in hours
  final double marginPercentage;
  final double deliveryCost;
  final String currency; // Store the currency used when quote was created
  final String? imagePath;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.name,
    required this.description,
    required this.recipes,
    required this.supplies,
    required this.timeRequired,
    required this.marginPercentage,
    required this.deliveryCost,
    required this.currency, // Required field
    this.imagePath,
    required this.createdAt,
  });

  double get totalIngredientCost {
    return recipes.fold(0.0, (sum, quoteRecipe) {
      // Get the current version of the recipe from DataService to ensure we have the latest ingredient quantities
      final dataService = DataService();
      final currentRecipe = dataService.recipes.firstWhere(
        (r) => r.id == quoteRecipe.recipe.id,
        orElse: () => quoteRecipe.recipe, // fallback to stored recipe if not found
      );
      
      return sum + currentRecipe.ingredients.fold(0.0, (recipeSum, recipeIngredient) {
        return recipeSum + ((recipeIngredient.ingredient.price / recipeIngredient.ingredient.quantity) * recipeIngredient.quantity * quoteRecipe.quantity);
      });
    });
  }

  double get totalSupplyCost {
    return supplies.fold(0.0, (sum, quoteSupply) {
      return sum + (quoteSupply.supply.price * quoteSupply.quantity);
    });
  }

  double get laborCost => timeRequired * SettingsService().pricePerHour;
  double get baseCost => totalIngredientCost + totalSupplyCost + laborCost;
  double get marginAmount => baseCost * (marginPercentage / 100);
  double get totalCost => baseCost + marginAmount + deliveryCost;

  // Get currency symbol for this quote
  String get currencySymbol {
    switch (currency) {
      case 'USD':
      case 'CAD':
      case 'AUD':
      case 'NZD':
      case 'SGD':
      case 'HKD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
      case 'CNY':
        return '¥';
      case 'CHF':
        return 'CHF';
      case 'INR':
        return '₹';
      case 'KRW':
        return '₩';
      case 'BRL':
        return 'R\$';
      case 'RUB':
        return '₽';
      default:
        return '\$';
    }
  }

  Map<String, dynamic> toJson() => {
    // Note: 'id' is NOT included - Firestore document ID is stored separately
    'name': name,
    'description': description,
    'recipes': recipes.map((e) => e.toJson()).toList(),
    'supplies': supplies.map((e) => e.toJson()).toList(),
    'timeRequired': timeRequired,
    'marginPercentage': marginPercentage,
    'deliveryCost': deliveryCost,
    'currency': currency,
    'imagePath': imagePath,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    recipes: (json['recipes'] as List?)
        ?.map((e) => QuoteRecipe.fromJson(e))
        .toList() ?? [],
    supplies: (json['supplies'] as List?)
        ?.map((e) => QuoteSupply.fromJson(e))
        .toList() ?? [],
  timeRequired: parseDouble(json['timeRequired'], 0.0),
  marginPercentage: parseDouble(json['marginPercentage'], 0.0),
  deliveryCost: parseDouble(json['deliveryCost'], 0.0),
    currency: json['currency'] ?? 'USD',
    imagePath: json['imagePath'],
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );
}