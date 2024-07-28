import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsManager {
  AnalyticsManager._privateConstructor();

  static final AnalyticsManager _instance =
      AnalyticsManager._privateConstructor();

  static AnalyticsManager get instance => _instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  bool _initialized = false;
  addEvent(String name, Map<String, dynamic> params) {
    analytics.logEvent(name: name, parameters: params);
    print('add event $name');
  }

  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
    }
  }
}
