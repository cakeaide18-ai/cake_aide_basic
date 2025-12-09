import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:cake_aide_basic/models/recipe.dart';
import 'package:cake_aide_basic/models/supply.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';

@immutable
class ShoppingListRecipe {
  final Recipe recipe;
  final double quantity;
  final bool isChecked;

  const ShoppingListRecipe({
    required this.recipe,
    required this.quantity,
    this.isChecked = false,
  });

  ShoppingListRecipe copyWith({
    Recipe? recipe,
    double? quantity,
    bool? isChecked,
  }) {
    return ShoppingListRecipe(
      recipe: recipe ?? this.recipe,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toMap() => {
        'recipe': recipe.toMap(),
        'quantity': quantity,
        'isChecked': isChecked,
      };

  Map<String, dynamic> toJson() => toMap();

  factory ShoppingListRecipe.fromJson(Map<String, dynamic> json) =>
      ShoppingListRecipe(
        recipe: Recipe.fromJson(json['recipe'] ?? {}),
        quantity: parseDouble(json['quantity']),
        isChecked: json['isChecked'] ?? false,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShoppingListRecipe &&
            other.recipe == recipe &&
            other.quantity == quantity &&
            other.isChecked == isChecked);
  }

  @override
  int get hashCode => Object.hash(recipe, quantity, isChecked);
}

@immutable
class ShoppingListSupply {
  final Supply supply;
  final double quantity;
  final bool isChecked;

  const ShoppingListSupply({
    required this.supply,
    required this.quantity,
    this.isChecked = false,
  });

  ShoppingListSupply copyWith({
    Supply? supply,
    double? quantity,
    bool? isChecked,
  }) {
    return ShoppingListSupply(
      supply: supply ?? this.supply,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toMap() => {
        'supply': supply.toMap(),
        'quantity': quantity,
        'isChecked': isChecked,
      };

  Map<String, dynamic> toJson() => toMap();

  factory ShoppingListSupply.fromJson(Map<String, dynamic> json) =>
      ShoppingListSupply(
        supply: Supply.fromJson(json['supply'] ?? {}),
        quantity: parseDouble(json['quantity']),
        isChecked: json['isChecked'] ?? false,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShoppingListSupply &&
            other.supply == supply &&
            other.quantity == quantity &&
            other.isChecked == isChecked);
  }

  @override
  int get hashCode => Object.hash(supply, quantity, isChecked);
}

@immutable
class ShoppingListIngredient {
  final Ingredient ingredient;
  final double quantity;
  final bool isChecked;

  const ShoppingListIngredient({
    required this.ingredient,
    required this.quantity,
    this.isChecked = false,
  });

  ShoppingListIngredient copyWith({
    Ingredient? ingredient,
    double? quantity,
    bool? isChecked,
  }) {
    return ShoppingListIngredient(
      ingredient: ingredient ?? this.ingredient,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  Map<String, dynamic> toMap() => {
        'ingredient': ingredient.toMap(),
        'quantity': quantity,
        'isChecked': isChecked,
      };

  Map<String, dynamic> toJson() => toMap();

  factory ShoppingListIngredient.fromJson(Map<String, dynamic> json) =>
      ShoppingListIngredient(
        ingredient: Ingredient.fromJson(json['ingredient'] ?? {}),
        quantity: parseDouble(json['quantity']),
        isChecked: json['isChecked'] ?? false,
      );

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShoppingListIngredient &&
            other.ingredient == ingredient &&
            other.quantity == quantity &&
            other.isChecked == isChecked);
  }

  @override
  int get hashCode => Object.hash(ingredient, quantity, isChecked);
}

@immutable
class ShoppingList {
  final String id;
  final String name;
  final List<ShoppingListRecipe> recipes;
  final List<ShoppingListSupply> supplies;
  final List<ShoppingListIngredient> ingredients;

  const ShoppingList({
    required this.id,
    required this.name,
    this.recipes = const [],
    this.supplies = const [],
    this.ingredients = const [],
  });

  ShoppingList copyWith({
    String? id,
    String? name,
    List<ShoppingListRecipe>? recipes,
    List<ShoppingListSupply>? supplies,
    List<ShoppingListIngredient>? ingredients,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      recipes: recipes ?? this.recipes,
      supplies: supplies ?? this.supplies,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'recipes': recipes.map((e) => e.toMap()).toList(),
        'supplies': supplies.map((e) => e.toMap()).toList(),
        'ingredients': ingredients.map((e) => e.toMap()).toList(),
      };

  Map<String, dynamic> toJson() => toMap();

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        id: parseString(json['id']),
        name: parseString(json['name']),
        recipes: (json['recipes'] as List? ?? [])
            .map((e) => ShoppingListRecipe.fromJson(e))
            .toList(),
        supplies: (json['supplies'] as List? ?? [])
            .map((e) => ShoppingListSupply.fromJson(e))
            .toList(),
        ingredients: (json['ingredients'] as List? ?? [])
            .map((e) => ShoppingListIngredient.fromJson(e))
            .toList(),
      );

  factory ShoppingList.fromFirestore(Map<String, dynamic> map, {String? id}) {
    final json = Map<String, dynamic>.from(map);
    if (id != null && (json['id'] == null || json['id'] == '')) {
      json['id'] = id;
    }
    return ShoppingList.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShoppingList &&
            other.id == id &&
            other.name == name &&
            const ListEquality().equals(other.recipes, recipes) &&
            const ListEquality().equals(other.supplies, supplies) &&
            const ListEquality().equals(other.ingredients, ingredients));
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        const ListEquality().hash(recipes),
        const ListEquality().hash(supplies),
        const ListEquality().hash(ingredients),
      );

  @override
  String toString() {
    return 'ShoppingList{id: $id, name: $name, recipes: ${recipes.length}, supplies: ${supplies.length}, ingredients: ${ingredients.length}}';
  }
}