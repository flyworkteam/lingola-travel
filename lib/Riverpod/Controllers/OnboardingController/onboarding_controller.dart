import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Repositories/profile_repository.dart';

/// Onboarding State Model
class OnboardingState {
  final String? targetLanguage;
  final String? targetLanguageCode; // ISO code (en, de, it, etc.)
  final String? profession;
  final String? englishLevel;
  final String? dailyGoal;
  final int? dailyGoalMinutes;
  final bool isLoading;
  final String? errorMessage;

  OnboardingState({
    this.targetLanguage,
    this.targetLanguageCode,
    this.profession,
    this.englishLevel,
    this.dailyGoal,
    this.dailyGoalMinutes,
    this.isLoading = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    String? targetLanguage,
    String? targetLanguageCode,
    String? profession,
    String? englishLevel,
    String? dailyGoal,
    int? dailyGoalMinutes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      targetLanguage: targetLanguage ?? this.targetLanguage,
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      profession: profession ?? this.profession,
      englishLevel: englishLevel ?? this.englishLevel,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Onboarding Controller
class OnboardingController extends StateNotifier<OnboardingState> {
  final ProfileRepository _profileRepository;

  OnboardingController(this._profileRepository) : super(OnboardingState());

  // Language name to ISO code mapping
  final Map<String, String> _languageCodes = {
    'English': 'en',
    'German': 'de',
    'Italian': 'it',
    'French': 'fr',
    'Japanese': 'ja',
    'Spanish': 'es',
    'Russian': 'ru',
    'Turkish': 'tr',
    'Korean': 'ko',
    'Hindi': 'hi',
    'Portuguese': 'pt',
  };

  /// Set target language
  void setTargetLanguage(String language) {
    final languageCode = _languageCodes[language] ?? 'en';
    state = state.copyWith(
      targetLanguage: language,
      targetLanguageCode: languageCode,
    );
  }

  /// Set profession
  void setProfession(String profession) {
    state = state.copyWith(profession: profession);
  }

  /// Set English level
  void setEnglishLevel(String level) {
    state = state.copyWith(englishLevel: level);
  }

  /// Set daily goal
  void setDailyGoal(String goal, int minutes) {
    state = state.copyWith(dailyGoal: goal, dailyGoalMinutes: minutes);
  }

  /// Save onboarding preferences to backend
  Future<bool> saveOnboarding() async {
    print('🟢 saveOnboarding called');
    print('🟢 Target language code: ${state.targetLanguageCode}');

    if (state.targetLanguageCode == null) {
      print('❌ No target language selected');
      state = state.copyWith(errorMessage: 'Lütfen bir dil seçin');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    print('🟢 Loading state set, calling API...');

    try {
      final response = await _profileRepository.saveOnboarding(
        targetLanguage: state.targetLanguageCode!,
        profession: state.profession,
        englishLevel: state.englishLevel,
        dailyGoal: state.dailyGoal,
        dailyGoalMinutes: state.dailyGoalMinutes,
      );

      print('🟢 API Response: ${response.success}');
      print('🟢 Response data: ${response.data}');
      print('🟢 Response error: ${response.error?.message}');

      if (response.success) {
        state = state.copyWith(isLoading: false);
        print('✅ Onboarding saved successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.error?.message ?? 'Tercihler kaydedilemedi',
        );
        print('❌ Save failed: ${state.errorMessage}');
        return false;
      }
    } catch (e) {
      print('❌ Exception in saveOnboarding: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Bir hata oluştu: $e',
      );
      return false;
    }
  }

  /// Reset state
  void reset() {
    state = OnboardingState();
  }
}

/// Provider for OnboardingController
final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
      return OnboardingController(ProfileRepository());
    });
