import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/user_profile.dart';

void main() {
  test('UserProfile JSON round-trip preserves fields', () {
    final original = UserProfile(
      id: 'user_1',
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      phone: '1234567890',
      businessName: 'Jane\'s Cakes',
      location: 'London',
      experienceLevel: 'Intermediate',
      businessType: 'Home Baker',
      bio: 'I love baking cakes!',
      profileImageUrl: 'https://example.com/jane.jpg',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 2),
    );

    final map = original.toMap();
    final restored = UserProfile.fromJson(map);

    expect(restored, equals(original));
    expect(restored.hashCode, equals(original.hashCode));
    expect(restored.toString().contains('Jane Doe'), isTrue);
  });
}
