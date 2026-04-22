import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../localization/app_strings.dart';
import 'providers/declare_islam_provider.dart';

import 'screens/intro_step.dart';
import 'screens/learn_step.dart';
import 'screens/readiness_step.dart';
import 'screens/confirmed_step.dart';

class DeclareIslamEntryScreen extends ConsumerWidget {
  const DeclareIslamEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(declareIslamProvider);

    // Determine Title based on step
    String titleKey = 'declare_islam';
    if (state.step == DeclareIslamStep.readiness) {
      titleKey = 'di_readiness_title';
    }

    // Determine Body
    Widget body = const SizedBox.shrink(); // Default initialization
    if (state.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      switch (state.step) {
        case DeclareIslamStep.intro:
          body = const IntroStepWidget();
          break;
        case DeclareIslamStep.learn:
          body = const LearnStepWidget();
          break;
        case DeclareIslamStep.readiness:
          body = const ReadinessStepWidget();
          break;
        case DeclareIslamStep.confirmed:
          body = const ConfirmedStepWidget();
          break;
      }
    }

    // Determine if we should intercept back navigation
    final bool shouldConfirmExit =
        state.step != DeclareIslamStep.intro &&
        state.step != DeclareIslamStep.confirmed &&
        !state.isLoading;

    return PopScope(
      canPop: !shouldConfirmExit,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await _showExitConfirmation(context);
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.of(context, titleKey)),
          centerTitle: true,
          leading:
              (state.step != DeclareIslamStep.intro &&
                      !state.isLoading &&
                      state.step != DeclareIslamStep.confirmed)
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // Custom back logic if needed, or just let the provider handle "back" logic
                      // But since we track steps, maybe we want back button to go to previous step?
                      // The native back button usually pops the screen.
                      // To support in-flow navigation, we should intercept back.
                      _handleBack(context, ref, state.step);
                    },
                  )
                  : null, // Default back button (pop) for Intro/Confirmed/Loading
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(key: ValueKey(state.step), child: body),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(AppStrings.of(context, 'di_exit_confirm_title')),
            content: Text(AppStrings.of(context, 'di_exit_confirm_body')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppStrings.of(context, 'di_exit_confirm_stay')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(AppStrings.of(context, 'di_exit_confirm_leave')),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  void _handleBack(
    BuildContext context,
    WidgetRef ref,
    DeclareIslamStep currentStep,
  ) {
    final notifier = ref.read(declareIslamProvider.notifier);
    switch (currentStep) {
      case DeclareIslamStep.learn:
        notifier.goToStep(DeclareIslamStep.intro);
        break;
      case DeclareIslamStep.readiness:
        notifier.goToStep(DeclareIslamStep.learn);
        break;
      case DeclareIslamStep.confirmed:
        // Should not happen as leading is null
        break;
      case DeclareIslamStep.intro:
        Navigator.pop(context);
        break;
    }
  }
}
