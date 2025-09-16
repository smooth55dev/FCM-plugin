import Foundation
import Tauri
import FirebaseMessaging
import FirebaseAnalytics
import UserNotifications

class SubscribeToTopicArgs: Decodable {
    let topic: String
}

class UnsubscribeFromTopicArgs: Decodable {
    let topic: String
}

@objc public class FcmPlugin: Plugin {
    
    override public func load(webview: WKWebView) {
        super.load(webview: webview)
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
        
        // Get FCM token
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.trigger("tokenReceived", data: ["token": token])
            }
        }
    }
    
    @objc public func getToken(_ invoke: Invoke) throws {
        Messaging.messaging().token { token, error in
            if let error = error {
                invoke.reject("Failed to get FCM token: \(error.localizedDescription)")
            } else if let token = token {
                invoke.resolve(token)
            } else {
                invoke.reject("No FCM token available")
            }
        }
    }
    
    @objc public func subscribeToTopic(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(SubscribeToTopicArgs.self)
        
        Messaging.messaging().subscribe(toTopic: args.topic) { error in
            if let error = error {
                invoke.reject("Failed to subscribe to topic: \(error.localizedDescription)")
            } else {
                invoke.resolve([:])
            }
        }
    }
    
    @objc public func unsubscribeFromTopic(_ invoke: Invoke) throws {
        let args = try invoke.parseArgs(UnsubscribeFromTopicArgs.self)
        
        Messaging.messaging().unsubscribe(fromTopic: args.topic) { error in
            if let error = error {
                invoke.reject("Failed to unsubscribe from topic: \(error.localizedDescription)")
            } else {
                invoke.resolve([:])
            }
        }
    }
    
    @objc public func areNotificationsEnabled(_ invoke: Invoke) throws {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let enabled = settings.authorizationStatus == .authorized
            invoke.resolve(enabled)
        }
    }
    
    @objc public func requestNotificationPermission(_ invoke: Invoke) throws {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                invoke.reject("Failed to request notification permission: \(error.localizedDescription)")
            } else {
                invoke.resolve(granted)
            }
        }
    }
    
    @objc open override func checkPermissions(_ invoke: Invoke) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .authorized:
                status = "granted"
            case .denied:
                status = "denied"
            case .notDetermined:
                status = "prompt"
            case .provisional:
                status = "granted"
            case .ephemeral:
                status = "granted"
            @unknown default:
                status = "prompt"
            }
            
            invoke.resolve(["postNotification": status])
        }
    }
    
    @objc public override func requestPermissions(_ invoke: Invoke) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            let status = granted ? "granted" : "denied"
            invoke.resolve(["postNotification": status])
        }
    }
}
