class UserProfile {
  final String id;
  final String name;
  final int age;
  final String goal; // e.g., "lose weight", "get fit", "stay healthy"
  final String? fcmToken;
  final DateTime? notificationTime;
  final bool notificationsEnabled;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.goal,
    this.fcmToken,
    this.notificationTime,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'goal': goal,
      'fcmToken': fcmToken,
      'notificationTime': notificationTime?.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      goal: json['goal'],
      fcmToken: json['fcmToken'],
      notificationTime: json['notificationTime'] != null
          ? DateTime.parse(json['notificationTime'])
          : null,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    String? goal,
    String? fcmToken,
    DateTime? notificationTime,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      fcmToken: fcmToken ?? this.fcmToken,
      notificationTime: notificationTime ?? this.notificationTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class HealthTip {
  final String id;
  final String title;
  final String content;
  final List<String> targetGoals;
  final List<String>
  targetAgeGroups; // e.g., ["18-25", "26-35", "36-50", "50+"]
  final String
  category; // e.g., "nutrition", "exercise", "mental_health", "sleep"

  HealthTip({
    required this.id,
    required this.title,
    required this.content,
    required this.targetGoals,
    required this.targetAgeGroups,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'targetGoals': targetGoals,
      'targetAgeGroups': targetAgeGroups,
      'category': category,
    };
  }

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      targetGoals: List<String>.from(json['targetGoals']),
      targetAgeGroups: List<String>.from(json['targetAgeGroups']),
      category: json['category'],
    );
  }
}
