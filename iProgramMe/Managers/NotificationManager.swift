//
//  NotificationManager.swift
//  iProgramMeExperiment1
//
//  Created by Pieter Yoshua Natanael on 30/09/23.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager {
    // Function to schedule a local notification
    static func scheduleNotification(notification: NotificationData, completion: @escaping (Bool, String) -> Void) {
        // Get the current notification center
        let center = UNUserNotificationCenter.current()
        
        // Request authorization for notifications
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // Check for errors during authorization
            if let error = error {
                // Handle the error and notify the completion handler
                print("Error requesting notification permission: \(error)")
                completion(false, "Error requesting notification permission")
                return
            }
            
            // Authorization granted, proceed to generate notification content
            let identifier = notification.id
            let content = UNMutableNotificationContent()
            
            // Set the notification title
            content.title = "iProgramMe"
            // Set the notification sound
            content.sound = UNNotificationSound.default
//            content.sound = UNNotificationSound(named: UNNotificationSoundName("flute"))

            // If there is notification text, set the body
            if let notificationText = notification.text {
                content.body = notificationText
            }
            
            // If there is a notification image, attempt to create a notification attachment
            if let notificationImage = notification.image {
                do {
                    if let attachment = try UNNotificationAttachment.create(
                        identifier: identifier,
                        image: notificationImage,
                        options: nil
                    ) {
                        content.attachments.append(attachment)
                    }
                } catch NotificationError.fileWriteFailed(let message) {
                    // Handle file write failure and notify the completion handler
                    completion(false, message)
                    return
                } catch NotificationError.imageSizeExceedsLimit(let message) {
                    // Handle image size exceeding the limit and notify the completion handler
                    completion(false, message)
                    return
                } catch NotificationError.imageDataCreationFailed(let message) {
                    // Handle image data creation failure and notify the completion handler
                    completion(false, message)
                    return
                } catch {
                    // Handle other unexpected errors and notify the completion handler
                    print("Unexpected error: \(error.localizedDescription)")
                    completion(false, error.localizedDescription)
                    return
                }
            }
            
            // Get date components from the notification time
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.hour, .minute], from: notification.notificationTime)
            
            // Set the trigger to fire at the specified time and repeat daily
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create the notification request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Schedule the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    // Handle scheduling error and notify the completion handler
                    print("Error scheduling notification: \(error)")
                    completion(false, "Error scheduling notification")
                    return
                } else {
                    // Notification scheduled successfully, notify the completion handler
                    print("Notification scheduled successfully.")
                    completion(true, "")
                    return
                }
            }
        }
    }

    // Function to load pending notifications and convert them to an array of NotificationData objects
    static func loadNotifications() -> [NotificationData] {
        // Commented out code for loading notifications from UserDefaults, not currently in use
        // if let data = UserDefaults.standard.data(forKey: "notificationsKey"),
        //    let decoded = try? JSONDecoder().decode([NotificationData].self, from: data) {
        //    return decoded
        // }
        // return []

        // Array to store pending notifications
        var pendingNotifications: [NotificationData] = []

        // Get the current notification center
        let center = UNUserNotificationCenter.current()

        // Start a dispatch group to handle the asynchronous nature of getPendingNotificationRequests
        let dispatchGroup = DispatchGroup()

        // Enter the dispatch group
        dispatchGroup.enter()

        // Asynchronously fetch pending notification requests
        center.getPendingNotificationRequests { requests in
            // Iterate through the fetched notification requests
            for request in requests {
                let content = request.content

                // Ensure that the trigger is of type UNCalendarNotificationTrigger
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {
                    // Skip this notification if the trigger is not of the expected type
                    return
                }
                
                // Create a NotificationData object with optional image data
                let storedNotification: NotificationData
                
                if let contentURL = content.attachments.first?.url, contentURL.startAccessingSecurityScopedResource() {
                    // Create a NotificationData object with image data from the content URL
                    storedNotification = NotificationData(
                        id: request.identifier,
                        text: content.body,
                        notificationTime: trigger.nextTriggerDate() ?? Date(),
                        image: Data(from: contentURL)
                    )
                    contentURL.stopAccessingSecurityScopedResource()
                } else {
                    // Create a NotificationData object without image data
                    storedNotification = NotificationData(
                        id: request.identifier,
                        text: content.body,
                        notificationTime: trigger.nextTriggerDate() ?? Date(),
                        image: nil
                    )
                }

                // Add the created NotificationData object to the array
                pendingNotifications.append(storedNotification)
            }

            // Leave the dispatch group when all notifications have been processed
            dispatchGroup.leave()
        }

        // Wait for the asynchronous operation to complete before continuing
        dispatchGroup.wait()

        // Print the pending notifications (for debugging purposes)
        // print(pendingNotifications)
        
        /*
         * Note:
         * To sort the pending notifications based on the time (ascending)
         * If this is used, please uncomment the following line:
         * 1) line 193 in ContentView.swift
         * 2) line 164, 167, and 170 in NotificationManager.swift
         *
         * Please comment out line 171 too!
         */
        
        // var sortedArray = sortNotificationsByTime(pendingNotifications)

        // Print the sorted notifications (for debugging purposes)
        // print(sortedArray)
        
        // Return the sorted array of pending notifications
        // return sortedArray
        return pendingNotifications
    }

//    static func saveNotifications(notifications: [NotificationData]) {
//        notifications.forEach { data in
//            print(data.text)
//        }
//
//        let encoder = JSONEncoder()
//        do {
//            let encoded = try encoder.encode(notifications)
//            UserDefaults.standard.set(encoded, forKey: "notificationsKey")
//        } catch {
//            print("ERROR: \(error.localizedDescription)")
//        }
//    }
    
    // Function to remove both delivered and pending notifications with a specific identifier
    static func removeNotification(identifier: String) {
        // Get the current notification center
        let center = UNUserNotificationCenter.current()

        // Remove delivered notifications with the specified identifier
        center.removeDeliveredNotifications(withIdentifiers: [identifier])

        // Remove pending notification requests with the specified identifier
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Function to sort notifications based on the time component of notificationTime
    static func sortNotificationsByTime(_ notifications: [NotificationData]) -> [NotificationData] {
        return notifications.sorted { (notification1, notification2) -> Bool in
            let timeComponent1 = Calendar.current.dateComponents([.hour, .minute, .second], from: notification1.notificationTime)
            let timeComponent2 = Calendar.current.dateComponents([.hour, .minute, .second], from: notification2.notificationTime)

            return timeComponent1.hour! < timeComponent2.hour!
        }
    }
}
