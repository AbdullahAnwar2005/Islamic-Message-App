import 'package:flutter/widgets.dart';
import 'analytics_service.dart';

class AnalyticsNavigatorObserver extends RouteObserver<PageRoute<dynamic>> {
  final AnalyticsService _analytics;

  AnalyticsNavigatorObserver(this._analytics);

  void _sendScreenView(PageRoute<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null) {
      _analytics.track(
        'screen_view',
        properties: {'screen_name': screenName, 'route': screenName},
      );
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
