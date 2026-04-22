import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alghaya_men_alkhalg/features/declare_islam/providers/declare_islam_provider.dart';
import 'package:alghaya_men_alkhalg/features/declare_islam/data/declare_islam_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state should be Intro', () async {
    // Trigger init
    container.read(declareIslamProvider);

    // Wait for async init to complete
    await Future.delayed(const Duration(milliseconds: 50));

    final state = container.read(declareIslamProvider);
    print('State: ${state.step}, Loading: ${state.isLoading}');

    expect(state.isLoading, false);
    expect(state.step, DeclareIslamStep.intro);
  });

  test('Readiness checks allow confirmation', () {
    final notifier = container.read(declareIslamProvider.notifier);

    expect(container.read(declareIslamProvider).canConfirm, false);

    notifier.toggleCheckUnderstood(true);
    notifier.toggleCheckChoice(true);
    notifier.toggleCheckSaid(true);

    expect(container.read(declareIslamProvider).canConfirm, true);
  });

  test('Confirming updates state and repository', () async {
    SharedPreferences.setMockInitialValues({});

    final notifier = container.read(declareIslamProvider.notifier);

    notifier.toggleCheckUnderstood(true);
    notifier.toggleCheckChoice(true);
    notifier.toggleCheckSaid(true);

    await notifier.confirmDeclaration('en');

    expect(
      container.read(declareIslamProvider).step,
      DeclareIslamStep.confirmed,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(DeclareIslamRepository.keyHasDeclared), true);
  });

  test('Undo clears state and repository', () async {
    SharedPreferences.setMockInitialValues({
      DeclareIslamRepository.keyHasDeclared: true,
    });

    final notifier = container.read(declareIslamProvider.notifier);
    // Init loads persisted state
    await Future.delayed(Duration.zero);

    // Should start at confirmed because of mock data
    // (Wait, the provider calls _init() in constructor but it's async state update)
    // We might need to listen or wait.

    // Let's force undo
    await notifier.undoDeclaration();

    expect(container.read(declareIslamProvider).step, DeclareIslamStep.intro);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(DeclareIslamRepository.keyHasDeclared), false);
  });
}
