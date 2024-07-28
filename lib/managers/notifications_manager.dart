import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {

  PushNotificationsManager._privateConstructor();

  static final PushNotificationsManager _instance = PushNotificationsManager._privateConstructor();

  static PushNotificationsManager get instance => _instance;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      firebaseMessaging.requestNotificationPermissions();
      firebaseMessaging.configure();

    // For testing purposes print the Firebase Messaging token
      // String token = await firebaseMessaging.getToken();
      
      // print("FirebaseMessaging token: $token");
      
      _initialized = true;
    }
  }
}