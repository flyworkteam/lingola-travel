import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Models/dictionary_model.dart';
import '../../Repositories/dictionary_repository.dart';

/// Dictionary View Model - Page state for Dictionary categories
class DictionaryViewModel {
  final bool isLoading;
  final String? errorMessage;
  final List<DictionaryCategoryModel> categories;

  const DictionaryViewModel({
    this.isLoading = false,
    this.errorMessage,
    this.categories = const [],
  });

  DictionaryViewModel copyWith({
    bool? isLoading,
    String? errorMessage,
    List<DictionaryCategoryModel>? categories,
  }) {
    return DictionaryViewModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      categories: categories ?? this.categories,
    );
  }
}

/// Dictionary Controller - Manages dictionary categories
class DictionaryController extends StateNotifier<DictionaryViewModel> {
  final DictionaryRepository _dictionaryRepository = DictionaryRepository();

  DictionaryController() : super(const DictionaryViewModel());

  /// Initialize dictionary - load categories
  Future<void> init() async {
    // Skip if already loaded or currently loading
    if (state.categories.isNotEmpty || state.isLoading) {
      print('📚 Dictionary categories already loaded, skipping init');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await loadCategories();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize dictionary',
      );
    }
  }

  /// Load all dictionary categories from API
  Future<void> loadCategories() async {
    try {
      final response = await _dictionaryRepository.getCategories();

      if (response.success && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          categories: response.data!,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error?.message ?? 'Failed to load categories',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Refresh categories
  Future<void> refresh() async {
    await loadCategories();
  }
}

/// Provider for Dictionary Controller
/// Global provider - categories are shared across pages
final dictionaryControllerProvider =
    StateNotifierProvider<DictionaryController, DictionaryViewModel>((ref) {
      return DictionaryController();
    });
