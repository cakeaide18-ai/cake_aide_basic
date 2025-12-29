import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderPriority { 
  low, 
  medium, 
  high;
  
  String toJson() => name;
  
  static ReminderPriority fromJson(String value) {
    return ReminderPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReminderPriority.medium,
    );
  }
}

class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final bool isCompleted;
  final ReminderPriority priority;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.isCompleted = false,
    this.priority = ReminderPriority.medium,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      // Note: 'id' is NOT included - Firestore document ID is stored separately
      'title': title,
      'description': description,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'isCompleted': isCompleted,
      'priority': priority.toJson(),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      scheduledTime: (json['scheduledTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: json['isCompleted'] ?? false,
      priority: ReminderPriority.fromJson(json['priority'] ?? 'medium'),
      notes: json['notes'] ?? '',
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    bool? isCompleted,
    ReminderPriority? priority,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
