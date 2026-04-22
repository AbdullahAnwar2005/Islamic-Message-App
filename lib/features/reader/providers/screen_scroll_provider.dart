import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In-memory store (simple). Persist with SharedPreferences later if you want.
final _positions = <String, double>{};

final readerScrollControllerProvider =
Provider.family<ScrollController, int>((ref, messageId) {
  final key = 'reader:$messageId';
  final controller = ScrollController(initialScrollOffset: _positions[key] ?? 0.0);

  controller.addListener(() {
    _positions[key] = controller.offset;
  });

  ref.onDispose(controller.dispose);
  return controller;
});


/// Riverpod Notifier that controls the visibility of the reader “chrome”
/// (AppBar + Bottom bar). `true` = visible, `false` = hidden.
class ChromeVisibility extends Notifier<bool> {
  @override
  bool build() => true; // start visible

  void show() => state = true;
  void hide() => state = false;
  void toggle() => state = !state;
}

/// Read: `ref.watch(chromeVisibilityProvider)` -> bool
/// Write: `ref.read(chromeVisibilityProvider.notifier).hide();`
final chromeVisibilityProvider =
NotifierProvider<ChromeVisibility, bool>(ChromeVisibility.new);

/// (Optional) Helper you can call from a NotificationListener<ScrollNotification>
/// to auto-hide on downward scroll and show on upward scroll.
void handleUserScrollForChrome(
    WidgetRef ref,
    UserScrollNotification n, {
      double threshold = 0.0,
    }) {
  // You can tune this logic later; simple and effective for now:
  if (n.direction == ScrollDirection.reverse) {
    ref.read(chromeVisibilityProvider.notifier).hide();
  } else if (n.direction == ScrollDirection.forward) {
    ref.read(chromeVisibilityProvider.notifier).show();
  }
}
class ChromeVisibilityNotifier extends StateNotifier<bool> {
  ChromeVisibilityNotifier() : super(true); // visible by default

  void show() {
    if (!state) state = true;
  }

  void hide() {
    if (state) state = false;
  }

  void toggle() => state = !state;
}


