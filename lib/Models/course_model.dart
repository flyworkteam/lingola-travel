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
  final int id;
  final int courseId;
  final String title;
  final String titleTr;
  final String? content;
  final String? contentTr;
  final int lessonNumber;
  final int? orderIndex;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.titleTr,
    this.content,
    this.contentTr,
    required this.lessonNumber,
    this.orderIndex,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      title: json['title'] as String,
      titleTr: json['title_tr'] as String,
      content: json['content'] as String?,
      contentTr: json['content_tr'] as String?,
      lessonNumber: json['lesson_number'] as int,
      orderIndex: json['order_index'] as int?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'title_tr': titleTr,
      'content': content,
      'content_tr': contentTr,
      'lesson_number': lessonNumber,
      'order_index': orderIndex,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    courseId,
    title,
    titleTr,
    content,
    contentTr,
    lessonNumber,
    orderIndex,
    isActive,
    createdAt,
    updatedAt,
  ];
}

/// Lesson Vocabulary Model - Words/phrases in a lesson
class LessonVocabularyModel extends Equatable {
  final int id;
  final int lessonId;
  final String word;
  final String wordTr;
  final String? pronunciation;
  final String? exampleSentence;
  final String? exampleSentenceTr;
  final String? audioUrl;
  final int? orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LessonVocabularyModel({
    required this.id,
    required this.lessonId,
    required this.word,
    required this.wordTr,
    this.pronunciation,
    this.exampleSentence,
    this.exampleSentenceTr,
    this.audioUrl,
    this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LessonVocabularyModel.fromJson(Map<String, dynamic> json) {
    return LessonVocabularyModel(
      id: json['id'] as int,
      lessonId: json['lesson_id'] as int,
      word: json['word'] as String,
      wordTr: json['word_tr'] as String,
      pronunciation: json['pronunciation'] as String?,
      exampleSentence: json['example_sentence'] as String?,
      exampleSentenceTr: json['example_sentence_tr'] as String?,
      audioUrl: json['audio_url'] as String?,
      orderIndex: json['order_index'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'word': word,
      'word_tr': wordTr,
      'pronunciation': pronunciation,
      'example_sentence': exampleSentence,
      'example_sentence_tr': exampleSentenceTr,
      'audio_url': audioUrl,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    lessonId,
    word,
    wordTr,
    pronunciation,
    exampleSentence,
    exampleSentenceTr,
    audioUrl,
    orderIndex,
    createdAt,
    updatedAt,
  ];
}
