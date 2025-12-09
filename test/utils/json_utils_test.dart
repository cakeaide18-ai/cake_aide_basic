import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';

void main() {
  group('parseDouble', () {
    test('parses numeric types', () {
      expect(parseDouble(1), 1.0);
      expect(parseDouble(1.5), 1.5);
    });

    test('parses numeric strings', () {
      expect(parseDouble('2.5'), 2.5);
      expect(parseDouble('3'), 3.0);
    });

    test('returns fallback for invalid input', () {
      expect(parseDouble(null), 0.0);
      expect(parseDouble('not-a-number', 4.2), 4.2);
    });
  });
}
