import 'package:equatable/equatable.dart';

/// Library Folder Model
class LibraryFolderModel extends Equatable {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final int itemCount;
  final DateTime createdAt;

  const LibraryFolderModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.itemCount,
    required this.createdAt,
  });

  factory LibraryFolderModel.fromJson(Map<String, dynamic> json) {
    return LibraryFolderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      itemCount: json['item_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'item_count': itemCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, name, icon, color, itemCount, createdAt];
}

/// Library Item Model - Klasördeki kelime veya cümle
class LibraryItemModel extends Equatable {
  final int libraryItemId; // library_items tablosundaki ID
  final String
  itemType; // 'dictionary_word', 'travel_phrase', 'lesson_vocabulary'
  final String itemId; // Gerçek item ID (word_id, phrase_id, etc.)
  final String word; // İngilizce kelime veya cümle (nullable for safety)
  final String translation; // Türkçe çeviri (nullable for safety)
  final String? audioUrl; // Ses dosyası URL
  final String? imageUrl; // Görsel URL (sadece dictionary_word için)
  final String? category; // Kategori (Airport, Food, etc.)
  final String? sourceLanguage; // tr
  final String? targetLanguage; // de, en, fr, etc.
  final DateTime createdAt; // Klasöre eklenme tarihi

  const LibraryItemModel({
    required this.libraryItemId,
    required this.itemType,
    required this.itemId,
    required this.word,
    required this.translation,
    this.audioUrl,
    this.imageUrl,
    this.category,
    this.sourceLanguage,
    this.targetLanguage,
    required this.createdAt,
  });

  factory LibraryItemModel.fromJson(Map<String, dynamic> json) {
    return LibraryItemModel(
      libraryItemId: json['library_item_id'] as int,
      itemType: json['item_type'] as String,
      itemId: json['item_id'] as String,
      word: (json['word'] as String?) ?? 'Unknown',
      translation: (json['translation'] as String?) ?? 'Bilinmeyen',
      audioUrl: json['audio_url'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      sourceLanguage: json['source_language'] as String?,
      targetLanguage: json['target_language'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'library_item_id': libraryItemId,
      'item_type': itemType,
      'item_id': itemId,
      'word': word,
      'translation': translation,
      'audio_url': audioUrl,
      'image_url': imageUrl,
      'category': category,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Item tipi insan okunabilir formatta
  String get itemTypeDisplay {
    switch (itemType) {
      case 'dictionary_word':
        return 'Kelime';
      case 'travel_phrase':
        return 'Cümle';
      case 'lesson_vocabulary':
        return 'Ders Kelimesi';
      default:
        return 'Bilinmeyen';
    }
  }

  @override
  List<Object?> get props => [
    libraryItemId,
    itemType,
    itemId,
    word,
    translation,
    audioUrl,
    imageUrl,
    category,
    sourceLanguage,
    targetLanguage,
    createdAt,
  ];
}
