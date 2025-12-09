import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:cake_aide_basic/utils/json_utils.dart';

@immutable
class TimerRecording {
  final String id;
  final String activity;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final List<Duration> pausedDurations;
  final String? notes;
  final DateTime createdAt;

  const TimerRecording({
    required this.id,
    required this.activity,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.pausedDurations = const [],
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity': activity,
      'duration': duration.inSeconds,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'pausedDurations': pausedDurations.map((d) => d.inSeconds).toList(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory TimerRecording.fromJson(Map<String, dynamic> json) {
    return TimerRecording(
      id: parseString(json['id']),
      activity: parseString(json['activity']),
      duration: Duration(seconds: parseInt(json['duration'])),
      startTime: DateTime.parse(parseString(json['startTime'], DateTime(0).toIso8601String())),
      endTime: DateTime.parse(parseString(json['endTime'], DateTime(0).toIso8601String())),
      pausedDurations: (json['pausedDurations'] as List<dynamic>? ?? [])
          .map((seconds) => Duration(seconds: parseInt(seconds)))
          .toList(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(parseString(json['createdAt'], DateTime(0).toIso8601String())),
    );
  }

  factory TimerRecording.fromFirestore(Map<String, dynamic> map, {String? id}) {
    final json = Map<String, dynamic>.from(map);
    if (id != null && (json['id'] == null || json['id'] == '')) {
      json['id'] = id;
    }
    return TimerRecording.fromJson(json);
  }

  TimerRecording copyWith({
    String? id,
    String? activity,
    Duration? duration,
    DateTime? startTime,
    DateTime? endTime,
    List<Duration>? pausedDurations,
    String? notes,
    DateTime? createdAt,
  }) {
    return TimerRecording(
      id: id ?? this.id,
      activity: activity ?? this.activity,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pausedDurations: pausedDurations ?? this.pausedDurations,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TimerRecording &&
            other.id == id &&
            other.activity == activity &&
            other.duration == duration &&
            other.startTime == startTime &&
            other.endTime == endTime &&
            const ListEquality().equals(other.pausedDurations, pausedDurations) &&
            other.notes == notes &&
            other.createdAt == createdAt);
  }

  @override
  int get hashCode => Object.hash(
        id,
        activity,
        duration,
        startTime,
        endTime,
        const ListEquality().hash(pausedDurations),
        notes,
        createdAt,
      );

  @override
  String toString() {
    return 'TimerRecording{id: $id, activity: $activity, duration: $formattedDuration}';
  }

  String get formattedDuration {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}