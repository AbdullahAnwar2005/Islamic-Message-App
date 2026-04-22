import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final readerProgressProvider = StateNotifierProvider.family<
    ReaderProgressNotifier, double, int>(
      (ref, messageId) => ReaderProgressNotifier(messageId),
);

class ReaderProgressNotifier extends StateNotifier<double> {
  ReaderProgressNotifier(this.messageId) : super(0.0);

  final int messageId;
  Timer? _debounce;

  void save(double offset) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      state = offset;
      // persist using messageId
    });
  }

  Future<void> flush() async {
    _debounce?.cancel();
    // persist state
  }
}
