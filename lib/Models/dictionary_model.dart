import 'package:equatable/equatable.dart';

/// Dictionary Category Model - Backend'e göre güncellenmiş
class DictionaryCategoryModel extends Equatable {
  final String id; // dict-cat-001, dict-cat-002, etc. (STRING!)
  final String name; // Airport, Accommodation, etc.
  final String iconPath; // assets/icons/airport.png
  final String color; // #2E48F0
  final int displayOrder;
  final int wordCount;

  const DictionaryCategoryModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.color,
    required this.displayOrder,
    required this.wordCount,
  });

  factory DictionaryCategoryModel.fromJson(Map<String, dynamic> json) {
    return DictionaryCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconPath: json['icon_path'] as String,
      color: json['color'] as String,
      displayOrder: json['display_order'] as int,
      wordCount: json['word_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_path': iconPath,
      'color': color,
      'display_order': displayOrder,
      'word_count': wordCount,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    iconPath,
    color,
    displayOrder,
    wordCount,
  ];
}

/// Dictionary Word Model
class DictionaryWordModel extends Equatable {
  final String id;
  final String categoryId;
  final String word;
  final String translation;
  final String? definition;
  final String? imageUrl;
  final String? audioUrl;
  final bool isBookmarked;
  final String? sourceLanguage; // tr
  final String? targetLanguage; // de, en, fr, etc.

  const DictionaryWordModel({
    required this.id,
    required this.categoryId,
    required this.word,
    required this.translation,
    this.definition,
    this.imageUrl,
    this.audioUrl,
    this.isBookmarked = false,
    this.sourceLanguage,
    this.targetLanguage,
  });

  factory DictionaryWordModel.fromJson(Map<String, dynamic> json) {
    return DictionaryWordModel(
      id: json['id'].toString(),
      categoryId: json['category_id']?.toString() ?? '',
      word: json['word'] as String,
      translation: json['translation'] as String,
      definition: json['definition'] as String?,
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      isBookmarked: json['is_bookmarked'] == 1 || json['is_bookmarked'] == true,
      sourceLanguage: json['source_language'] as String?,
      targetLanguage: json['target_language'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'word': word,
      'translation': translation,
      'definition': definition,
      'image_url': imageUrl,
      'audio_url': audioUrl,
      'is_bookmarked': isBookmarked,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
    };
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    word,
    translation,
    definition,
    imageUrl,
    audioUrl,
    isBookmarked,
    sourceLanguage,
    targetLanguage,
  ];
}
