import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';

enum OrderStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

@immutable
class Order {
  final String id;
  final String name;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final OrderStatus status;
  final DateTime? orderDate;
  final DateTime? deliveryDate;
  final TimeOfDay? deliveryTime;
  final String notes;
  final String cakeDetails;
  final int servings;
  final double price;
  final bool isCustomDesign;
  final String customDesignNotes;
  // Persisted image references for the order's photos. Can be URLs or base64 strings.
  final List<String> imageUrls;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Order({
    required this.id,
    required this.name,
    required this.customerName,
    this.customerPhone = '',
    this.customerEmail = '',
    required this.status,
    this.orderDate,
    this.deliveryDate,
    this.deliveryTime,
    this.notes = '',
    this.cakeDetails = '',
    this.servings = 0,
    this.price = 0.0,
    this.isCustomDesign = false,
    this.customDesignNotes = '',
    this.imageUrls = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: parseString(json['id']),
      name: parseString(json['name']),
      customerName: parseString(json['customerName']),
      customerPhone: parseString(json['customerPhone']),
      customerEmail: parseString(json['customerEmail']),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      orderDate: _parseDate(json['orderDate']),
      deliveryDate: _parseDate(json['deliveryDate']),
      deliveryTime: _parseTimeOfDay(json['deliveryTime']),
      notes: parseString(json['notes']),
      cakeDetails: parseString(json['cakeDetails']),
      servings: parseInt(json['servings']),
      price: parseDouble(json['price']),
      isCustomDesign: json['isCustomDesign'] ?? false,
      customDesignNotes: parseString(json['customDesignNotes']),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  factory Order.fromFirestore(Map<String, dynamic> map, {String? id}) {
    final json = Map<String, dynamic>.from(map);
    if (id != null && (json['id'] == null || json['id'] == '')) {
      json['id'] = id;
    }
    return Order.fromJson(json);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'status': status.name,
      'orderDate': orderDate,
      'deliveryDate': deliveryDate,
      'deliveryTime': deliveryTime != null ? '${deliveryTime!.hour}:${deliveryTime!.minute}' : null,
      'notes': notes,
      'cakeDetails': cakeDetails,
      'servings': servings,
      'price': price,
      'isCustomDesign': isCustomDesign,
      'customDesignNotes': customDesignNotes,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  Order copyWith({
    String? name,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    OrderStatus? status,
    DateTime? orderDate,
    DateTime? deliveryDate,
    TimeOfDay? deliveryTime,
    String? notes,
    String? cakeDetails,
    int? servings,
    double? price,
    bool? isCustomDesign,
    String? customDesignNotes,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id,
      name: name ?? this.name,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      notes: notes ?? this.notes,
      cakeDetails: cakeDetails ?? this.cakeDetails,
      servings: servings ?? this.servings,
      price: price ?? this.price,
      isCustomDesign: isCustomDesign ?? this.isCustomDesign,
      customDesignNotes: customDesignNotes ?? this.customDesignNotes,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Order &&
            other.id == id &&
            other.name == name &&
            other.customerName == customerName &&
            other.customerPhone == customerPhone &&
            other.customerEmail == customerEmail &&
            other.status == status &&
            other.orderDate == orderDate &&
            other.deliveryDate == deliveryDate &&
            other.deliveryTime == deliveryTime &&
            other.notes == notes &&
            other.cakeDetails == cakeDetails &&
            other.servings == servings &&
            other.price == price &&
            other.isCustomDesign == isCustomDesign &&
            other.customDesignNotes == customDesignNotes &&
            const ListEquality().equals(other.imageUrls, imageUrls) &&
            other.createdAt == createdAt &&
            other.updatedAt == updatedAt);
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        customerName,
        customerPhone,
        customerEmail,
        status,
        orderDate,
        deliveryDate,
        deliveryTime,
        notes,
        cakeDetails,
        servings,
        price,
        isCustomDesign,
        customDesignNotes,
        const ListEquality().hash(imageUrls),
        createdAt,
        updatedAt,
      );

  @override
  String toString() {
    return 'Order{id: $id, name: $name, customerName: $customerName, status: $status, deliveryDate: $deliveryDate, price: $price}';
  }
}

DateTime? _parseDate(dynamic date) {
  if (date is Timestamp) {
    return date.toDate();
  }
  if (date is String) {
    return DateTime.tryParse(date);
  }
  if (date is DateTime) {
    return date;
  }
  return null;
}

TimeOfDay? _parseTimeOfDay(String? time) {
  if (time == null) {
    return null;
  }
  final parts = time.split(':');
  if (parts.length != 2) {
    return null;
  }
  return TimeOfDay(
    hour: int.tryParse(parts[0]) ?? 0,
    minute: int.tryParse(parts[1]) ?? 0,
  );
}