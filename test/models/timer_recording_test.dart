import 'package:flutter_test/flutter_test.dart';
import 'package:cake_aide_basic/models/timer_recording.dart';

void main() {
  test('TimerRecording JSON round-trip preserves fields', () {
    final original = TimerRecording(
      id: 'tr_1',
      activity: 'Baking',
      duration: const Duration(minutes: 30),
      startTime: DateTime(2025, 12, 24, 10, 0),
      endTime: DateTime(2025, 12, 24, 10, 30),
      createdAt: DateTime(2025, 12, 24, 10, 0),
    );

    final map = original.toMap();
    final restored = TimerRecording.fromJson(map);

    expect(restored, equals(original));
    expect(restored.hashCode, equals(original.hashCode));
    expect(restored.toString().contains('Baking'), isTrue);
  });
}
