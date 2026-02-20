import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/dictionary_model.dart';
import '../../Repositories/dictionary_repository.dart';

/// Visual Dictionary Words View Model
class VisualDictionaryWordsViewModel {
  final bool isLoading;
  final String? errorMessage;
  final List<DictionaryWordModel> words;
  final String? categoryName;

  const VisualDictionaryWordsViewModel({
    this.isLoading = false,
    this.errorMessage,
    this.words = const [],
    this.categoryName,
  });

  VisualDictionaryWordsViewModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DictionaryWordModel>? words,
    String? categoryName,
  }) {
    return VisualDictionaryWordsViewModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      words: words ?? this.words,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

/// Visual Dictionary Words Controller - Manages words for a specific category
class VisualDictionaryWordsController
    extends StateNotifier<VisualDictionaryWordsViewModel> {
  final DictionaryRepository _dictionaryRepository = DictionaryRepository();
  final String categoryId;

  VisualDictionaryWordsController({required this.categoryId})
    : super(const VisualDictionaryWordsViewModel());

  /// Initialize and load words for the category
  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await loadWords();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize words',
      );
    }
  }

  /// Load words for the specific category
  Future<void> loadWords() async {
    try {
      final response = await _dictionaryRepository.getWordsByCategory(
        categoryId: categoryId,
        limit: 200,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          words: response.data!,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error?.message ?? 'Failed to load words',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Search words locally
  void searchWords(String query) {
    if (query.isEmpty) {
      // Reset to full list
      loadWords();
      return;
    }

    final filteredWords = state.words.where((word) {
      return word.word.toLowerCase().contains(query.toLowerCase()) ||
          word.translation.toLowerCase().contains(query.toLowerCase());
    }).toList();

    state = state.copyWith(words: filteredWords);
  }

  /// Refresh words
  Future<void> refresh() async {
    await loadWords();
  }
}

/// Provider factory for Visual Dictionary Words Controller
/// Use this with .family to create separate instances for each category
final visualDictionaryWordsControllerProvider =
    StateNotifierProvider.family<
      VisualDictionaryWordsController,
      VisualDictionaryWordsViewModel,
      String
    >((ref, categoryId) {
      return VisualDictionaryWordsController(categoryId: categoryId);
    });
