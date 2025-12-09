import 'package:meta/meta.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';

@immutable
class Ingredient {
  /// Document id (Firestore document id is preferred). May be empty for
  /// transient objects created on the client.
  final String id;

  /// Human readable name of the ingredient. Must not be empty.
  final String name;

  /// Optional brand name. Use an empty string when unknown.
  final String brand;

  /// Price per unit in [currency]. Must be >= 0.
  final double price;

  /// Unit for the quantity (e.g. "kg", "g", "ml"). Must not be empty.
  final String unit;

  /// Currency symbol or code (kept as string for display). Defaults to '£'.
  final String currency;

  /// Quantity available/required. Must be >= 0.
  final double quantity;

  const Ingredient({
    required this.id,
    required this.name,
    this.brand = '',
    required this.price,
    required this.unit,
    required this.quantity,
    this.currency = '£',
  }) : assert(name != ''),
       assert(unit != ''),
       assert(price >= 0),
       assert(quantity >= 0);

  /// Convert to a plain map suitable for Firestore or JSON encoding.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'price': price,
        'unit': unit,
        'currency': currency,
        'quantity': quantity,
      };

  /// Alias for toMap kept for backward compatibility.
  Map<String, dynamic> toJson() => toMap();

  /// Create an Ingredient from a decoded JSON / Firestore map.
  /// Uses safe parsing helpers to avoid throwing on unexpected types.
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: parseString(json['id'], ''),
      name: parseString(json['name'], ''),
      brand: parseString(json['brand'], ''),
      price: parseDouble(json['price'], 0.0),
      unit: parseString(json['unit'], ''),
      currency: parseString(json['currency'], '£'),
      quantity: parseDouble(json['quantity'], 1.0),
    );
  }

  /// Helper to create an Ingredient from a Firestore document map. If the
  /// Firestore document id is provided separately, pass it via [id].
  factory Ingredient.fromFirestore(Map<String, dynamic> map, {String? id}) {
    final json = Map<String, dynamic>.from(map);
    if (id != null && (json['id'] == null || json['id'] == '')) {
      json['id'] = id;
    }
    return Ingredient.fromJson(json);
  }

  Ingredient copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    String? unit,
    String? currency,
    double? quantity,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Ingredient &&
            other.id == id &&
            other.name == name &&
            other.brand == brand &&
            other.price == price &&
            other.unit == unit &&
            other.currency == currency &&
            other.quantity == quantity);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        brand,
        price,
        unit,
        currency,
        quantity,
      );

  @override
  String toString() {
    return 'Ingredient{id: $id, name: $name, brand: $brand, price: $price, unit: $unit, currency: $currency, quantity: $quantity}';
  }
}