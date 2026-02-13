import 'package:equatable/equatable.dart';

/// Travel Phrase Model - Backend travel_phrases tablosundan geliyor
class TravelPhraseModel extends Equatable {
  final String id; // phrase-001, phrase-002, etc.
  final String category; // Airport, Hotel, etc.
  final String phraseType; // question, statement, response
  final String englishText;
  final String translation;
  final String? audioUrl;
  final bool isBookmarked;

  const TravelPhraseModel({
    required this.id,
    required this.category,
    required this.phraseType,
    required this.englishText,
    required this.translation,
    this.audioUrl,
    this.isBookmarked = false,
  });

  factory TravelPhraseModel.fromJson(Map<String, dynamic> json) {
    return TravelPhraseModel(
      id: json['id'] as String,
      category: json['category'] as String,
      phraseType: json['phrase_type'] as String,
      englishText: json['english_text'] as String,
      translation: json['translation'] as String,
      audioUrl: json['audio_url'] as String?,
      isBookmarked:
          (json['is_bookmarked'] == 1 || json['is_bookmarked'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'phrase_type': phraseType,
      'english_text': englishText,
      'translation': translation,
      'audio_url': audioUrl,
      'is_bookmarked': isBookmarked,
    };
  }

  @override
  List<Object?> get props => [
    id,
    category,
    phraseType,
    englishText,
    translation,
    audioUrl,
    isBookmarked,
  ];
}
