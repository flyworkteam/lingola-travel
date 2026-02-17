import 'package:equatable/equatable.dart';

/// Course Model - Represents a learning course (Backend'e göre güncellenmiş!)
class CourseModel extends Equatable {
  final String id; // course-001, course-002, etc. (STRING!)
  final String category; // General, Trip, Food & Drink, etc.
  final String title;
  final String description;
  final String imageUrl;
  final int totalLessons;
  final bool isFree;
  final int displayOrder;
  final int lessonsCompleted;
  final int progressPercentage;

  const CourseModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.totalLessons,
    required this.isFree,
    required this.displayOrder,
    this.lessonsCompleted = 0,
    this.progressPercentage = 0,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'General',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      totalLessons: json['total_lessons'] as int? ?? 0,
      isFree: (json['is_free'] as int? ?? 0) == 1,
      displayOrder: json['display_order'] as int? ?? 0,
      lessonsCompleted: json['lessons_completed'] as int? ?? 0,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'total_lessons': totalLessons,
      'is_free': isFree ? 1 : 0,
      'display_order': displayOrder,
      'lessons_completed': lessonsCompleted,
      'progress_percentage': progressPercentage,
    };
  }

  @override
  List<Object?> get props => [
    id,
    category,
    title,
    description,
    imageUrl,
    totalLessons,
    isFree,
    displayOrder,
    lessonsCompleted,
    progressPercentage,
  ];
}

/// Lesson Model - Represents a lesson within a course
class LessonModel extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String description;
  final String? exampleSentence;
  final String? keyVocabularyTerm;
  final int lessonOrder;
  final int totalSteps;
  final String? imageUrl;
  final String? audioUrl;
  final String targetLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userStatus;
  final int? userProgress;
  final int?
  currentUserStep; // User's current step in this lesson (from backend)
  final int? timeSpent;
  final DateTime? completedAt;
  final List<LessonVocabularyModel>? vocabulary;
  final String? courseImageUrl; // Course image from joined data

  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    this.exampleSentence,
    this.keyVocabularyTerm,
    required this.lessonOrder,
    required this.totalSteps,
    this.imageUrl,
    this.audioUrl,
    required this.targetLanguage,
    required this.createdAt,
    required this.updatedAt,
    this.userStatus,
    this.userProgress,
    this.currentUserStep,
    this.timeSpent,
    this.completedAt,
    this.vocabulary,
    this.courseImageUrl,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      exampleSentence: json['example_sentence'] as String?,
      keyVocabularyTerm: json['key_vocabulary_term'] as String?,
      lessonOrder: json['lesson_order'] as int,
      totalSteps: json['total_steps'] as int? ?? 10,
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      targetLanguage: json['target_language'] as String? ?? 'en',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      userStatus: json['user_status'] as String?,
      userProgress: _parseInt(json['user_progress']),
      currentUserStep: _parseInt(json['current_step']),
      timeSpent: _parseInt(json['time_spent']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      vocabulary: json['vocabulary'] != null
          ? (json['vocabulary'] as List)
                .map(
                  (v) =>
                      LessonVocabularyModel.fromJson(v as Map<String, dynamic>),
                )
                .toList()
          : null,
      courseImageUrl: json['course_image_url'] as String?,
    );
  }

  // Helper method to safely parse int from dynamic value
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.round();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'example_sentence': exampleSentence,
      'key_vocabulary_term': keyVocabularyTerm,
      'lesson_order': lessonOrder,
      'total_steps': totalSteps,
      'image_url': imageUrl,
      'audio_url': audioUrl,
      'target_language': targetLanguage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_status': userStatus,
      'user_progress': userProgress,
      'current_step': currentUserStep,
      'time_spent': timeSpent,
      'completed_at': completedAt?.toIso8601String(),
      'vocabulary': vocabulary?.map((v) => v.toJson()).toList(),
      'course_image_url': courseImageUrl,
    };
  }

  @override
  List<Object?> get props => [
    id,
    courseId,
    title,
    description,
    exampleSentence,
    keyVocabularyTerm,
    lessonOrder,
    totalSteps,
    imageUrl,
    audioUrl,
    targetLanguage,
    createdAt,
    updatedAt,
    userStatus,
    userProgress,
    currentUserStep,
    timeSpent,
    completedAt,
    vocabulary,
    courseImageUrl,
  ];
}

/// Lesson Vocabulary Model - Words/phrases in a lesson
class LessonVocabularyModel extends Equatable {
  final String id;
  final String? lessonId;
  final String term;
  final String definition;
  final String? iconPath;
  final String? iconColor;
  final String? audioUrl;
  final int? displayOrder;
  final String? sourceLanguage;
  final String targetLanguage;

  const LessonVocabularyModel({
    required this.id,
    this.lessonId,
    required this.term,
    required this.definition,
    this.iconPath,
    this.iconColor,
    this.audioUrl,
    this.displayOrder,
    this.sourceLanguage,
    required this.targetLanguage,
  });

  factory LessonVocabularyModel.fromJson(Map<String, dynamic> json) {
    return LessonVocabularyModel(
      id: json['id'] as String,
      lessonId: json['lesson_id'] as String?,
      term: json['term'] as String? ?? '',
      definition: json['definition'] as String? ?? '',
      iconPath: json['icon_path'] as String?,
      iconColor: json['icon_color'] as String?,
      audioUrl: json['audio_url'] as String?,
      displayOrder: _parseInt(json['display_order']),
      sourceLanguage: json['source_language'] as String?,
      targetLanguage: json['target_language'] as String? ?? 'en',
    );
  }

  // Helper method to safely parse int from dynamic value
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.round();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'term': term,
      'definition': definition,
      'icon_path': iconPath,
      'icon_color': iconColor,
      'audio_url': audioUrl,
      'display_order': displayOrder,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
    };
  }

  @override
  List<Object?> get props => [
    id,
    lessonId,
    term,
    definition,
    iconPath,
    iconColor,
    audioUrl,
    displayOrder,
    sourceLanguage,
    targetLanguage,
  ];
}
