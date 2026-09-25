import '../../tasks/models/task_category.dart';
import '../../tasks/models/task_priority.dart';

class AiSuggestedTask {
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final int dueHour;
  final int dueMinute;

  const AiSuggestedTask({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.dueHour = 20,
    this.dueMinute = 0,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category.name,
    'priority': priority.name,
    'dueHour': dueHour,
    'dueMinute': dueMinute,
  };

  factory AiSuggestedTask.fromJson(Map<String, dynamic> json) => AiSuggestedTask(
    title: json['title'] as String,
    description: json['description'] as String,
    category: TaskCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => TaskCategory.coding,
    ),
    priority: TaskPriority.values.firstWhere(
      (p) => p.name == json['priority'],
      orElse: () => TaskPriority.medium,
    ),
    dueHour: (json['dueHour'] as num?)?.toInt() ?? 20,
    dueMinute: (json['dueMinute'] as num?)?.toInt() ?? 0,
  );
}

class AiChatMessage {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final List<AiSuggestedTask>? suggestedTasks;
  final String? categoryTag;

  const AiChatMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.suggestedTasks,
    this.categoryTag,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'isUser': isUser,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'suggestedTasks': suggestedTasks?.map((t) => t.toJson()).toList(),
    'categoryTag': categoryTag,
  };

  factory AiChatMessage.fromJson(Map<String, dynamic> json) => AiChatMessage(
    id: json['id'] as String,
    isUser: json['isUser'] as bool,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    suggestedTasks: (json['suggestedTasks'] as List<dynamic>?)
        ?.map((e) => AiSuggestedTask.fromJson(e as Map<String, dynamic>))
        .toList(),
    categoryTag: json['categoryTag'] as String?,
  );
}
