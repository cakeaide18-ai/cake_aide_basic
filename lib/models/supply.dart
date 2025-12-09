import 'package:meta/meta.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';

@immutable
class Supply {
  /// Document id (Firestore document id is preferred). May be empty for
  /// transient objects created on the client.
  final String id;

  /// Human readable name of the supply. Must not be empty.
  final String name;

  /// Optional brand name. Use an empty string when unknown.
  final String brand;

  /// Price per unit in [currency]. Must be >= 0.
  final double price;

  /// Quantity available/required. Must be >= 0.
  final double quantity;

  /// Unit for the quantity (e.g., 'pieces', 'kg', 'boxes'). Must not be empty.
  final String unit;

  /// Currency symbol or code (kept as string for display). Defaults to '£'.
  final String currency;

  const Supply({
    required this.id,
    required this.name,
    this.brand = '',
    required this.price,
    required this.quantity,
    required this.unit,
    this.currency = '£',
  })  : assert(name != ''),
        assert(unit != ''),
        assert(price >= 0),
        assert(quantity >= 0);

  /// Convert to a plain map suitable for Firestore or JSON encoding.
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'price': price,
        'quantity': quantity,
        'unit': unit,
        'currency': currency,
      };

  /// Alias for toMap kept for backward compatibility.
  Map<String, dynamic> toJson() => toMap();

  /// Create a Supply from a decoded JSON / Firestore map.
  /// Uses safe parsing helpers to avoid throwing on unexpected types.
  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
      id: parseString(json['id'], ''),
      name: parseString(json['name'], ''),
      brand: parseString(json['brand'], ''),
      price: parseDouble(json['price'], 0.0),
      quantity: parseDouble(json['quantity'], 0.0),
      unit: parseString(json['unit'], ''),
      currency: parseString(json['currency'], '£'),
    );
  }

  /// Helper to create a Supply from a Firestore document map. If the
  /// Firestore document id is provided separately, pass it via [id].
  factory Supply.fromFirestore(Map<String, dynamic> map, {String? id}) {
    final json = Map<String, dynamic>.from(map);
    if (id != null && (json['id'] == null || json['id'] == '')) {
      json['id'] = id;
    }
    return Supply.fromJson(json);
  }

  Supply copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    double? quantity,
    String? unit,
    String? currency,
  }) {
    return Supply(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      currency: currency ?? this.currency,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Supply &&
            other.id == id &&
            other.name == name &&
            other.brand == brand &&
            other.price == price &&
            other.quantity == quantity &&
            other.unit == unit &&
            other.currency == currency);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        brand,
        price,
        quantity,
        unit,
        currency,
      );

  @override
  String toString() {
    return 'Supply{id: $id, name: $name, brand: $brand, price: $price, quantity: $quantity, unit: $unit, currency: $currency}';
  }
}