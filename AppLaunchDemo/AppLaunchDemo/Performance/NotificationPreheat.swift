//
//  NotificationService.swift
//  SwiftPamphletApp
//
//  Created by Ming on 2024/11/11.
//

import Foundation
import UserNotifications
import SwiftUI

struct NotificationPreheatDemoView: View {
    var body: some View {
        VStack {
            Button("Request notification authorization.") {
                NotificationService.shared.requestAuthorization { granted in
                    if granted {
                        print("Authorization successful.")
                    } else {
                        print("Authorization failed.")
                    }
                }
            }
            
            Button("Schedule notification.") {
                NotificationService.shared.scheduleNotification(title: "Preload Lib", body: "This is a notification demo", timeInterval: 5)
            }
        }
        .padding()
    }
}

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    @MainActor static let shared = NotificationService()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Authorization error: \(error.localizedDescription)")
                completion(false)
                return
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error.localizedDescription)")
            }
        }
    }
    
    // Deal with recieved notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Processing notifications in the foreground of the App
        print("Recieved notification：\(notification.request.content.title)")
        if notification.request.content.title == "Preload Lib" {
            preloadSystemLibraries()
            completionHandler([.sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Processing user click notification behavior
        print("User clicked notification: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
    private func preloadSystemLibraries() {
        // Use dlopen preload main App common used system lib
        let libraries = [
            "/usr/lib/libobjc.A.dylib",
            "/System/Library/Frameworks/UIKit.framework/UIKit",
            "/System/Library/Frameworks/Foundation.framework/Foundation"
        ]
        
        for library in libraries {
            dlopen(library, RTLD_NOW)
        }
    }
}
