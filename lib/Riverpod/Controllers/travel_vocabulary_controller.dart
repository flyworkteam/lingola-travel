import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/travel_phrase_model.dart';
import '../../Models/dictionary_model.dart'; // Only for DictionaryWordModel type
import '../../Repositories/travel_phrase_repository.dart';

// Provider for repository
final travelPhraseRepositoryProvider = Provider<TravelPhraseRepository>((ref) {
  return TravelPhraseRepository();
});

// ViewModel for state
class TravelVocabularyViewModel {
  final List<TravelPhraseModel> phrases;
  final List<DictionaryWordModel> words;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedCategory;

  const TravelVocabularyViewModel({
    this.phrases = const [],
    this.words = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory,
  });

  TravelVocabularyViewModel copyWith({
    List<TravelPhraseModel>? phrases,
    List<DictionaryWordModel>? words,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
  }) {
    return TravelVocabularyViewModel(
      phrases: phrases ?? this.phrases,
      words: words ?? this.words,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// Controller
class TravelVocabularyController
    extends StateNotifier<TravelVocabularyViewModel> {
  final TravelPhraseRepository _phraseRepository;

  TravelVocabularyController(this._phraseRepository)
    : super(const TravelVocabularyViewModel());

  /// Initialize and load both
  Future<void> init() async {
    await loadAll(categoryName: 'All Topics');
  }

  /// Load everything for a category
  Future<void> loadAll({String? categoryName}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      selectedCategory: categoryName,
      words: [], // Empty - not used anymore
      phrases: [],
    );

    try {
      // Travel Vocabulary shows ONLY PHRASES (travel_phrases table)
      // Words are shown in Visual Dictionary (dictionary_words table)

      // Load phrases (categoryName 'All Topics' ise null gönderiyoruz ki hepsi gelsin)
      final effectiveCategory =
          (categoryName == 'All Topics' || categoryName == null)
          ? null
          : categoryName;
      final phraseResp = await _phraseRepository.getPhrasesByCategory(
        effectiveCategory,
      );

      state = state.copyWith(
        phrases: phraseResp.data ?? [],
        words: [], // Not used in Travel Vocabulary
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  /// Filter by category
  Future<void> filterByCategory(String? category) async {
    await loadAll(categoryName: category);
  }
}

// Provider for controller - COMPLETELY NORMAL (NO autoDispose)
// This prevents premature disposal during audio/TTS operations
final travelVocabularyControllerProvider =
    StateNotifierProvider<
      TravelVocabularyController,
      TravelVocabularyViewModel
    >((ref) {
      final phraseRepo = ref.watch(travelPhraseRepositoryProvider);
      return TravelVocabularyController(phraseRepo);
    });
