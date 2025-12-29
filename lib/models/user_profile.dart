import 'package:meta/meta.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';

@immutable
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String businessName;
  final String location;
  final String experienceLevel;
  final String businessType;
  final String bio;
  final String profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
    required this.location,
    required this.experienceLevel,
    required this.businessType,
    required this.bio,
    required this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? businessName,
    String? location,
    String? experienceLevel,
    String? businessType,
    String? bio,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      businessType: businessType ?? this.businessType,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'businessName': businessName,
      'location': location,
      'experienceLevel': experienceLevel,
      'businessType': businessType,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'owner_id': id, // Add owner_id field for Firestore security rules
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: parseString(json['id']),
      name: parseString(json['name']),
      email: parseString(json['email']),
      phone: parseString(json['phone']),
      businessName: parseString(json['businessName']),
      location: parseString(json['location']),
      experienceLevel: parseString(json['experienceLevel']),
      businessType: parseString(json['businessType']),
      bio: parseString(json['bio']),
      profileImageUrl: parseString(json['profileImageUrl']),
      createdAt: DateTime.tryParse(parseString(json['createdAt'])),
      updatedAt: DateTime.tryParse(parseString(json['updatedAt'])),
    );
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> map, {String? id}) {
    final json = Map<String, dynamic>.from(map);
    if (id != null && (json['id'] == null || json['id'] == '')) {
      json['id'] = id;
    }
    return UserProfile.fromJson(json);
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, businessName: $businessName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.businessName == businessName &&
        other.location == location &&
        other.experienceLevel == experienceLevel &&
        other.businessType == businessType &&
        other.bio == bio &&
        other.profileImageUrl == profileImageUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        businessName.hashCode ^
        location.hashCode ^
        experienceLevel.hashCode ^
        businessType.hashCode ^
        bio.hashCode ^
        profileImageUrl.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}