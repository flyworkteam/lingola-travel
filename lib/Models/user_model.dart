/// User Model
class UserModel {
  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isAnonymous;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final DateTime? trialStartedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? targetLanguage; // de, it, fr, es, etc.
  final String? profession;
  final String? englishLevel;
  final String? dailyGoal;
  final int? dailyGoalMinutes;

  UserModel({
    required this.id,
    this.email,
    this.name,
    this.photoUrl,
    this.phoneNumber,
    this.isAnonymous = false,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.trialStartedAt,
    required this.createdAt,
    required this.updatedAt,
    this.targetLanguage,
    this.profession,
    this.englishLevel,
    this.dailyGoal,
    this.dailyGoalMinutes,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      photoUrl: json['photo_url']?.toString(), // Backend snake_case
      phoneNumber: json['phone_number']?.toString(), // Backend snake_case
      isAnonymous:
          (json['is_anonymous'] == 1 ||
          json['is_anonymous'] == true), // Backend may send 1 or true
      isPremium:
          (json['is_premium'] == 1 ||
          json['is_premium'] == true), // Backend may send 1 or true
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.tryParse(json['premium_expires_at'].toString())
          : null,
      trialStartedAt: json['trial_started_at'] != null
          ? DateTime.tryParse(json['trial_started_at'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(), // Backend snake_case
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(), // Backend snake_case
      targetLanguage: json['target_language']?.toString(),
      profession: json['profession']?.toString(),
      englishLevel: json['english_level']?.toString(),
      dailyGoal: json['daily_goal']?.toString(),
      dailyGoalMinutes: json['daily_goal_minutes'] != null
          ? int.tryParse(json['daily_goal_minutes'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'isAnonymous': isAnonymous,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'trialStartedAt': trialStartedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'target_language': targetLanguage,
      'profession': profession,
      'english_level': englishLevel,
      'daily_goal': dailyGoal,
      'daily_goal_minutes': dailyGoalMinutes,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    bool? isAnonymous,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    DateTime? trialStartedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? targetLanguage,
    String? profession,
    String? englishLevel,
    String? dailyGoal,
    int? dailyGoalMinutes,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      profession: profession ?? this.profession,
      englishLevel: englishLevel ?? this.englishLevel,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
    );
  }

  /// Check if premium trial is active
  bool get isTrialActive {
    if (trialStartedAt == null) return false;
    final trialEnd = trialStartedAt!.add(const Duration(days: 1));
    return DateTime.now().isBefore(trialEnd);
  }

  /// Check if user has premium access (either trial or paid)
  bool get hasPremiumAccess {
    return isPremium || isTrialActive;
  }
}
