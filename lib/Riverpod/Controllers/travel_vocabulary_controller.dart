import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/travel_phrase_model.dart';
import '../../Models/dictionary_model.dart' hide TravelPhraseModel;
import '../../Models/api_response.dart';
import '../../Repositories/travel_phrase_repository.dart';
import '../../Repositories/dictionary_repository.dart';
import 'dictionary_controller.dart';

// Provider for repository
final travelPhraseRepositoryProvider = Provider<TravelPhraseRepository>((ref) {
  return TravelPhraseRepository();
});

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return DictionaryRepository();
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
  final DictionaryRepository _dictionaryRepository;
  final Ref _ref;

  TravelVocabularyController(
    this._phraseRepository,
    this._dictionaryRepository,
    this._ref,
  ) : super(const TravelVocabularyViewModel());

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
      words: [],
      phrases: [],
    );

    try {
      // 1. Kategorilerin yüklenmiş olduğundan emin olalım
      var dictionaryState = _ref.read(dictionaryControllerProvider);
      if (dictionaryState.categories.isEmpty) {
        await _ref.read(dictionaryControllerProvider.notifier).init();
        dictionaryState = _ref.read(dictionaryControllerProvider);
      }

      // 2. Cümleleri Yükle (categoryName 'All Topics' ise null gönderiyoruz ki hepsi gelsin)
      final effectiveCategory =
          (categoryName == 'All Topics' || categoryName == null)
          ? null
          : categoryName;
      final phraseResp = await _phraseRepository.getPhrasesByCategory(
        effectiveCategory,
      );

      // 3. Kelimeleri Yükle
      List<DictionaryWordModel> words = [];

      if (effectiveCategory != null) {
        // Belirli bir kategori seçildiyse:
        final category = dictionaryState.categories.firstWhere(
          (c) => c.name == effectiveCategory,
          orElse: () =>
              throw Exception('Category "$effectiveCategory" not found'),
        );

        final wordResp = await _dictionaryRepository.getWordsByCategory(
          categoryId: category.id,
        );
        if (wordResp.success) words = wordResp.data ?? [];
      } else {
        // "All Topics" seçildiyse (Başlangıç ekranı):
        // Çeşitlilik için ilk 5 kategoriden 10'ar kelime çekelim
        final topCategories = dictionaryState.categories.take(5).toList();
        final List<Future<ApiResponse<List<DictionaryWordModel>>>> futures =
            topCategories
                .map(
                  (c) => _dictionaryRepository.getWordsByCategory(
                    categoryId: c.id,
                    limit: 10,
                  ),
                )
                .toList();

        final resultsArr = await Future.wait(futures);
        for (var res in resultsArr) {
          if (res.success && res.data != null) {
            words.addAll(res.data!);
          }
        }
        // Kelimeleri karıştırabiliriz (Opsiyonel)
        words.shuffle();
      }

      state = state.copyWith(
        phrases: phraseResp.data ?? [],
        words: words,
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

// Provider for controller
final travelVocabularyControllerProvider =
    StateNotifierProvider<
      TravelVocabularyController,
      TravelVocabularyViewModel
    >((ref) {
      final phraseRepo = ref.watch(travelPhraseRepositoryProvider);
      final dictRepo = ref.watch(dictionaryRepositoryProvider);
      return TravelVocabularyController(phraseRepo, dictRepo, ref);
    });
