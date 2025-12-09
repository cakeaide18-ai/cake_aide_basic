import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:cake_aide_basic/models/ingredient.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';

@immutable
class RecipeIngredient {
  final Ingredient ingredient;
  final double quantity;
  final String unit;

  const RecipeIngredient({
    required this.ingredient,
    required this.quantity,
    required this.unit,
  })  : assert(quantity >= 0),
        assert(unit != '');

  Map<String, dynamic> toMap() => {
        'ingredient': ingredient.toMap(),
        'quantity': quantity,
        'unit': unit,
      };

  Map<String, dynamic> toJson() => toMap();

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      ingredient: Ingredient.fromJson(json['ingredient'] ?? {}),
      quantity: parseDouble(json['quantity']),
      unit: parseString(json['unit']),
    );
  }

  RecipeIngredient copyWith({
    Ingredient? ingredient,
    double? quantity,
    String? unit,
  }) {
    return RecipeIngredient(
      ingredient: ingredient ?? this.ingredient,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RecipeIngredient &&
            other.ingredient == ingredient &&
            other.quantity == quantity &&
            other.unit == unit);
  }

  @override
  int get hashCode => Object.hash(ingredient, quantity, unit);
}

@immutable
class Recipe {
  final String id;
  final String name;
  final String cakeSizePortions;
  final List<RecipeIngredient> ingredients;
  final String? imagePath;

  const Recipe({
    required this.id,
    required this.name,
    required this.cakeSizePortions,
    required this.ingredients,
    this.imagePath,
  }) : assert(name != '');

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'cakeSizePortions': cakeSizePortions,
        'ingredients': ingredients.map((e) => e.toMap()).toList(),
        'imagePath': imagePath,
      };

  Map<String, dynamic> toJson() => toMap();

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: parseString(json['id']),
      name: parseString(json['name']),
      cakeSizePortions: parseString(json['cakeSizePortions']),
      ingredients: (json['ingredients'] as List? ?? [])
          .map((e) => RecipeIngredient.fromJson(e))
          .toList(),
      imagePath: json['imagePath'] as String?,
    );
  }

  factory Recipe.fromFirestore(Map<String, dynamic> map, {String? id}) {
    final json = Map<String, dynamic>.from(map);
    if (id != null && (json['id'] == null || json['id'] == '')) {
      json['id'] = id;
    }
    return Recipe.fromJson(json);
  }

  Recipe copyWith({
    String? id,
    String? name,
    String? cakeSizePortions,
    List<RecipeIngredient>? ingredients,
    String? imagePath,
    bool forceImagePathToNull = false,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      cakeSizePortions: cakeSizePortions ?? this.cakeSizePortions,
      ingredients: ingredients ?? this.ingredients,
      imagePath: forceImagePathToNull ? null : imagePath ?? this.imagePath,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Recipe &&
            other.id == id &&
            other.name == name &&
            other.cakeSizePortions == cakeSizePortions &&
            const ListEquality().equals(other.ingredients, ingredients) &&
            other.imagePath == imagePath);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        cakeSizePortions,
        const ListEquality().hash(ingredients),
        imagePath,
      );

  @override
  String toString() {
    return 'Recipe{id: $id, name: $name, cakeSizePortions: $cakeSizePortions, ingredients: $ingredients, imagePath: $imagePath}';
  }
}