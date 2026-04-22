import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/declare_islam_repository.dart';

// States for the flow
enum DeclareIslamStep { intro, learn, readiness, confirmed }

class DeclareIslamState {
  final DeclareIslamStep step;
  final bool isLoading;
  // Readiness checks
  final bool checkUnderstood;
  final bool checkChoice;
  final bool checkSaid;

  const DeclareIslamState({
    this.step = DeclareIslamStep.intro,
    this.isLoading = true, // Start loading to check persistence
    this.checkUnderstood = false,
    this.checkChoice = false,
    this.checkSaid = false,
  });

  bool get canConfirm => checkUnderstood && checkChoice && checkSaid;

  DeclareIslamState copyWith({
    DeclareIslamStep? step,
    bool? isLoading,
    bool? checkUnderstood,
    bool? checkChoice,
    bool? checkSaid,
  }) {
    return DeclareIslamState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      checkUnderstood: checkUnderstood ?? this.checkUnderstood,
      checkChoice: checkChoice ?? this.checkChoice,
      checkSaid: checkSaid ?? this.checkSaid,
    );
  }
}

class DeclareIslamNotifier extends StateNotifier<DeclareIslamState> {
  final DeclareIslamRepository _repository;

  DeclareIslamNotifier(this._repository) : super(const DeclareIslamState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);
    final hasDeclared = await _repository.hasDeclared();
    if (hasDeclared) {
      state = state.copyWith(
        step: DeclareIslamStep.confirmed,
        isLoading: false,
      );
    } else {
      state = state.copyWith(step: DeclareIslamStep.intro, isLoading: false);
    }
  }

  void goToStep(DeclareIslamStep step) {
    state = state.copyWith(step: step);
  }

  void toggleCheckUnderstood(bool value) {
    state = state.copyWith(checkUnderstood: value);
  }

  void toggleCheckChoice(bool value) {
    state = state.copyWith(checkChoice: value);
  }

  void toggleCheckSaid(bool value) {
    state = state.copyWith(checkSaid: value);
  }

  Future<void> confirmDeclaration(String languageCode) async {
    if (!state.canConfirm) return;

    await _repository.setDeclared(languageCode: languageCode);
    state = state.copyWith(step: DeclareIslamStep.confirmed);
  }

  Future<void> undoDeclaration() async {
    await _repository.clearDeclaration();
    // Reset all checks
    state = const DeclareIslamState(
      step: DeclareIslamStep.intro,
      isLoading: false,
    );
  }
}

final declareIslamRepositoryProvider = Provider(
  (ref) => DeclareIslamRepository(),
);

final declareIslamProvider =
    StateNotifierProvider<DeclareIslamNotifier, DeclareIslamState>((ref) {
      final repo = ref.watch(declareIslamRepositoryProvider);
      return DeclareIslamNotifier(repo);
    });
