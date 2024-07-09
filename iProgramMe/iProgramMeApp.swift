//
//  iProgramMeApp.swift
//  iProgramMe
//
//  Created by Pieter Yoshua Natanael on 27/09/23.
//

import SwiftUI

@main
struct iProgramMeApp: App {
    // Create an instance of the NotificationDelegate class and assign it to the private variable 'delegate'.
    private var delegate: NotificationDelegate = NotificationDelegate()

    // Initialize the class.
    init() {
        // Get the current instance of UNUserNotificationCenter.
        let current = UNUserNotificationCenter.current()
        
        // Set the delegate of UNUserNotificationCenter to the created instance of NotificationDelegate.
        current.delegate = delegate
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
