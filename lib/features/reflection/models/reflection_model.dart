class ReflectionModel {
  final String id;
  final String userId;
  final DateTime date;
  final String accomplishments;
  final String challenges;
  final String tomorrowPlan;
  final int rating; // 1 to 5 stars
  final DateTime createdAt;

  const ReflectionModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.accomplishments,
    required this.challenges,
    required this.tomorrowPlan,
    this.rating = 5,
    required this.createdAt,
  });

  ReflectionModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? accomplishments,
    String? challenges,
    String? tomorrowPlan,
    int? rating,
    DateTime? createdAt,
  }) {
    return ReflectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      accomplishments: accomplishments ?? this.accomplishments,
      challenges: challenges ?? this.challenges,
      tomorrowPlan: tomorrowPlan ?? this.tomorrowPlan,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'accomplishments': accomplishments,
      'challenges': challenges,
      'tomorrowPlan': tomorrowPlan,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReflectionModel.fromJson(Map<String, dynamic> json) {
    return ReflectionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      accomplishments: json['accomplishments'] as String? ?? '',
      challenges: json['challenges'] as String? ?? '',
      tomorrowPlan: json['tomorrowPlan'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
