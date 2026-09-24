import 'task_category.dart';
import 'task_priority.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TaskCategory category;
  final DateTime dueDate;
  final int dueHour;
  final int dueMinute;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool hasReminder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.category,
    required this.dueDate,
    this.dueHour = 23,
    this.dueMinute = 59,
    required this.priority,
    this.isCompleted = false,
    this.completedAt,
    this.hasReminder = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DateTime get dueDateTime => DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        dueHour,
        dueMinute,
      );

  bool get isMissed {
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDateTime);
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskCategory? category,
    DateTime? dueDate,
    int? dueHour,
    int? dueMinute,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? completedAt,
    bool? hasReminder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      dueHour: dueHour ?? this.dueHour,
      dueMinute: dueMinute ?? this.dueMinute,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      hasReminder: hasReminder ?? this.hasReminder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.name,
      'dueDate': dueDate.toIso8601String(),
      'dueHour': dueHour,
      'dueMinute': dueMinute,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'hasReminder': hasReminder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: TaskCategory.fromString(json['category'] as String? ?? 'personal'),
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : DateTime.now(),
      dueHour: json['dueHour'] as int? ?? 23,
      dueMinute: json['dueMinute'] as int? ?? 59,
      priority: TaskPriority.fromString(json['priority'] as String? ?? 'medium'),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      hasReminder: json['hasReminder'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }
}
