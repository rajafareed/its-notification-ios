import UIKit  // Add this import to your file
import FirebaseMessaging
import UserNotifications
import FirebaseCore


public protocol NotificationSDKDelegate: AnyObject {
    func didReceiveNotification(title: String?, body: String?)
}

public class NotificationHandler: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    public static let shared = NotificationHandler()
    public weak var delegate: NotificationSDKDelegate?

    private override init() {
        super.init()
    }

    public func configure(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }

    public func processRemoteNotification(userInfo: [AnyHashable: Any]) {
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: String] {
            let title = alert["title"]
            let body = alert["body"]
            delegate?.didReceiveNotification(title: title, body: body)
        }
    }

    // MARK: - Firebase Messaging Delegate

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token from SDK: \(fcmToken ?? "")")
   
    }

    // MARK: - Foreground Notification

    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    
    func configureFirebase(apiKey: String,
                           googleAppID: String) {
        
        
        let firebaseOptions = FirebaseOptions(googleAppID: googleAppID,
            gcmSenderID: "590518950252")

        firebaseOptions.apiKey = apiKey
        firebaseOptions.bundleID = "its-notification-library"
        firebaseOptions.projectID = "parent-app-eb9dd"
        
        FirebaseApp.configure(options: firebaseOptions)
        
        
        
        // If you're in an app that uses the Swift package, use Bundle.main to access resources
//        if let resourceURL = Bundle.main.url(forResource: "Resources/GoogleService-Info", withExtension: "plist"),
//
//            
//            
//            
//            let options = FirebaseOptions(contentsOfFile: resourceURL.path) {
//
//
//            FirebaseApp.configure(options: options)
//        }
    }

}
