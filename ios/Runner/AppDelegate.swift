import UIKit
import Flutter
import NeuraSDK
import CoreLocation
import FirebaseAuth


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let locationManager = CLLocationManager()
    var authenticateChannel : FlutterMethodChannel!
    var refreshDataChannel: FlutterMethodChannel!
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        NeuraSDK.shared.setAppUID("us-FjnKKOVyLWjXn2sDHkSLS_5lOb89AhgmKhKG86sNDCU", appSecret: "BZwssLQH1ZRcj0CAIWAGKxpIuvdkZkrCm9YCeOOulF4")
        UIApplication.shared.setMinimumBackgroundFetchInterval(1800)
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        authenticateChannel = FlutterMethodChannel(name: "com.neura.flutterApp/authenticate",
                                                       binaryMessenger: controller.binaryMessenger)
         refreshDataChannel = FlutterMethodChannel(name: "net.nadsoft.peloton/tokenUpdateChannel",
                  binaryMessenger: controller.binaryMessenger)
                  
     
     
        //locationManager.requestAlwaysAuthorization()
        authenticateChannel.setMethodCallHandler{ (call, result) in
            self.authenticate(flutterResult: result)
        }
        GeneratedPluginRegistrant.register(with: self)
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
        NeuraSDK.shared.authenticationDelegate = self
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let firebaseAuth = Auth.auth()
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
        NeuraSDKPushNotification.registerDeviceToken(deviceToken)
        print("devide token ios : ",deviceToken)
        refreshDataChannel.invokeMethod("updateToken", arguments: deviceToken.reduce("", {$0 + String(format: "%02X", $1)}))

    }
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("new noti ***")
        if NeuraSDKPushNotification.handleNeuraPush(withInfo: userInfo, fetchCompletionHandler: completionHandler) {
            // A Neura notification was consumed and handled.
            // The SDK will call the completion handler.
            return
        }
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        completionHandler(.noData)
    }
    
    
    override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NeuraSDK.shared.collectDataForBGFetch { result in
            completionHandler(result)
        }
    }
    
    private func authenticate(flutterResult: @escaping FlutterResult) {
        guard !NeuraSDK.shared.isAuthenticated() else {
            UserDefaults.standard.set(NeuraSDK.shared.accessToken(), forKey: "neuraAccessToken")
            flutterResult(NeuraSDK.shared.accessToken() ?? "isAuthenticated")
            return
        }
        let request = NeuraAnonymousAuthenticationRequest()
        NeuraSDK.shared.authenticate(with: request){ result in
            UserDefaults.standard.set(result.info?.accessToken , forKey: "neuraAccessToken")
            flutterResult(result.info?.accessToken ?? "fail")
        }
    }
}
extension AppDelegate : NeuraAuthenticationDelegate {
    func neuraAccessTokenChanged(_ newAccessToken: String?) {
        guard let token = newAccessToken else {return}
        UserDefaults.standard.set(token, forKey: "neuraAccessToken")
        authenticateChannel.invokeMethod("updateToken", arguments: token)
       
    }
}
