import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'analytics_service.dart';

/// Manages when to trigger a flush of the analytics queue.
class AnalyticsFlushScheduler with WidgetsBindingObserver {
  final AnalyticsService _service;
  Timer? _timer;
  StreamSubscription? _connectivitySub;

  AnalyticsFlushScheduler(this._service);

  void start() {
    WidgetsBinding.instance.addObserver(this);

    // Periodic flush (every 60s)
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _service.flush();
    });

    // Connectivity change flush
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        _service.flush();
      }
    });
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _connectivitySub?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Attempt flush when going to background or paused
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _service.flush();
    }
  }
}
