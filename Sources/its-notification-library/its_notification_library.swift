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

    
    public func setAPNsToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs token set in SDK")

        // Now safe to request FCM token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("❌ Failed to fetch FCM token after setting APNs token: \(error.localizedDescription)")
            } else if let token = token {
                print("📲 FCM Token (after APNs): \(token)")
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
    
    
   public func configureFirebase(apiKey: String,
                           googleAppID: String,bundleID: String) {
        
//       guard FirebaseApp.app() == nil else {
//                  print("Firebase already configured")
//                  return
//              }
//      

       
        let options = FirebaseOptions(googleAppID: googleAppID,
            gcmSenderID: "590518950252")

       options.apiKey = apiKey
       options.bundleID = bundleID
       options.projectID = "parent-app-eb9dd"
        
       FirebaseApp.configure(options: options)
             print("✅ Firebase configured with custom options")
        
        
        
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
