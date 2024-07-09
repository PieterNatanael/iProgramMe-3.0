//
//  NotificationDelegate.swift
//  iProgramMe
//
//  Created by Jonathan Lee on 29/12/23.
//

import SwiftUI

// Define a class named NotificationDelegate that conforms to NSObject and UNUserNotificationCenterDelegate.
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // Function called when a user interacts with a notification outside the app.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Get the content of the notification.
        let content = response.notification.request.content
        
        // Extract the URL of the first attachment in the notification content.
        let notificationAttachmentURL = content.attachments.first?.url
        
        // Extract the body text of the notification.
        let notificationBody = content.body
        
        // Update the shared AppState with the extracted information.
        AppState.shared.imageURL = notificationAttachmentURL
        AppState.shared.bodyText = notificationBody
        AppState.shared.openPreviewSheet = true
        
        // Call the completion handler to signal that the notification handling is complete.
        completionHandler()
    }
    
    // Function called when a notification is received while the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Extract the URL of the first attachment in the notification content.
        let notificationAttachmentURL = notification.request.content.attachments.first?.url
        
        // Update the shared AppState with the extracted information.
        AppState.shared.imageURL = notificationAttachmentURL
        
        // Specify the presentation options for the notification (e.g., banner, sound, badge).
        completionHandler([.banner, .sound, .badge])
    }
}
