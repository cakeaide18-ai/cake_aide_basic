import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/repositories/firebase_repository.dart';

class _Dummy {}

class DummyRepository extends FirebaseRepository<_Dummy> {
  DummyRepository(): super(
    collectionName: 'dummy',
    fromMap: (m) => _Dummy(),
    toMap: (d) => <String, dynamic>{},
  );
}

void main() {
  group('FirebaseRepository auth gating', () {
    test('add throws when user not authenticated', () async {
      final repo = DummyRepository();
      expect(() => repo.add(_Dummy()), throwsA(isA<Exception>()));
    });

    test('getAll returns empty when unauthenticated', () async {
      final repo = DummyRepository();
      final all = await repo.getAll();
      expect(all, isEmpty);
    });
  });
}
