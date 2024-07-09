//
//  ContentView.swift
//  iProgramMe
//
//  Created by Pieter Yoshua Natanael on 27/09/23.
//

import SwiftUI
import PhotosUI
import UserNotifications

// Define a SwiftUI view named ContentView.
struct ContentView: View {
    
    // State variables to manage the view's data.
    @State private var notifications: [NotificationData] = []
    @State private var newText = ""
    @State private var selectedTime = Date()
    @State private var isShowingSplash = false
    
    // Alert state variables.
    @State private var isShowingAlert = false
    @State private var alertMessage: String = ""
    
    // Photo picker state variables.
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // Sheet state variables.
    @State private var showAddNotificationView = false
    
    // Observed object to handle notification preview image.
    @ObservedObject var appState = AppState.shared
    
    // State variables for list preview image.
    @State private var showPreviewListImage = false
    @State private var previewListImage: Data? = nil
    @State private var previewListText: String? = nil
    
    // Define the body of the ContentView.
    var body: some View {
        
        // NavigationStack allows easy navigation handling.
        NavigationStack {
            
            // Check if the splash screen is currently being shown.
            if isShowingSplash {
                SplashView(isShowingSplash: $isShowingSplash)
            } else {
                // Main content area with a list of notifications.
                List {
                    ForEach(notifications, id: \.id) { notification in
                        
                        // Display different buttons based on the content of the notification.
                        if let imageData = notification.image, let imageText = notification.text, let uiImage = UIImage(data: imageData) {
                            // If there is both an image and text.
                            Button {
                                previewListImage = imageData
                                previewListText = imageText
                                showPreviewListImage = true
                            } label: {
                                // Display the image and text.
                                HStack(spacing: 8) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                    
                                    Text("\(notification.text ?? "") at \(formatTime(notification.notificationTime))")
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        else if let imageData = notification.image, let uiImage = UIImage(data: imageData) {
                            // If there is only an image.
                            Button {
                                previewListImage = imageData
                                previewListText = nil
                                showPreviewListImage = true
                            } label: {
                                // Display the image only.
                                HStack(spacing: 8) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                    Text("\(formatTime(notification.notificationTime))")
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        else if let imageText = notification.text {
                            // If there is only text.
                            Button {
                                previewListText = imageText
                                previewListImage = nil
                                showPreviewListImage = true
                            } label: {
                                // Display the text only.
                                Text("\(notification.text ?? "") at \(formatTime(notification.notificationTime))")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete(perform: deleteNotification)
                }
                .navigationBarTitle("iProgramMe")
                .onAppear(perform: loadNotifications)
                .overlay {
                    // Display a message if there are no notifications.
                    if (notifications.isEmpty) {
                        Text("There's no notification. Try add one!")
                    }
                }
                
                // Sheet to add notifications.
                .sheet(isPresented: $showAddNotificationView, content: {
                    AddNotificationView(
                        selectedImage: $selectedImage,
                        selectedImageData: $selectedImageData,
                        newText: $newText, selectedTime: $selectedTime,
                        showAddNotificationSheet: $showAddNotificationView,
                        addNotification: addNotification
                    )
                })
                
                // Sheet to preview the image on the list.
                .sheet(isPresented: $showPreviewListImage, content: {
                    PreviewListImageView(
                        showPreviewListImage: $showPreviewListImage,
                        previewListImage: $previewListImage,
                        previewListText: $previewListText
                    )
                })
                
                // Sheet to show notification image.
                .sheet(isPresented: $appState.openPreviewSheet, content: {
                    NotificationImageView()
                })
                
                // Alert for displaying messages.
                .alert(isPresented: $isShowingAlert, content: {
                    Alert(title: Text(alertMessage))
                })
                
                // Toolbar with buttons for adding and deleting notifications.
                .toolbar(content: {
                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button {
                            // Reset form values.
                            resetFormValue()
                            
                            // Show the notification sheet.
                            showAddNotificationView.toggle()
                        } label: {
                            Label("Add new notification", systemImage: "plus")
                        }
                    }
                })
            }
        }
    }
    
    // Function to reset form values.
    func resetFormValue() {
        newText = ""
        selectedImage = nil
        selectedImageData = nil
        selectedTime = Date()
    }

    // Function to add a new notification.
    func addNotification() {
        // Instantiate a new notification data object.
        let newNotification = NotificationData(
            text: newText.isEmpty ? nil : newText,
            notificationTime: selectedTime,
            image: selectedImageData
        )

        // Schedule the notification.
        NotificationManager.scheduleNotification(notification: newNotification) {
            success, message in
            
            if success {
                // Notification scheduled successfully.
                // Append to the current state.
                notifications.append(newNotification)
                
                // To sort the pending notifications based on the time (ascending)
                // notifications = NotificationManager.sortNotificationsByTime(notifications)
                
                // Save the notification to local storage.
                // saveNotifications()
            } else {
                // Notification scheduling failed.
                // Show an alert.
                alertMessage = message
                isShowingAlert.toggle()
            }
        }
    }

    // Function to delete a notification.
    func deleteNotification(at offsets: IndexSet) {
        // Get the index.
        guard let index = offsets.first else {return;}
        
        // Get the relevant notification ID to be removed from the schedule.
        let notificationId = notifications[index].id
        
        // Remove the notifications.
        notifications.remove(atOffsets: offsets)
        
        // Remove the notifications.
        NotificationManager.removeNotification(identifier: notificationId)
        
        // Commented out code that call function to save notifications.
        // saveNotifications()
    }

    // Function to format the time for display.
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Function to load notifications.
    func loadNotifications() {
        notifications = NotificationManager.loadNotifications()
    }

    // Commented out function to save notifications to local storage.
    // func saveNotifications() {

    //    NotificationManager.saveNotifications(notifications: notifications)
    // }
}



#Preview {
    ContentView()
}


/*
//work well, but I want to add ads and downgrade to ios14
import SwiftUI
import PhotosUI
import UserNotifications

// Define a SwiftUI view named ContentView.
struct ContentView: View {
    
    // State variables to manage the view's data.
    @State private var notifications: [NotificationData] = []
    @State private var newText = ""
    @State private var selectedTime = Date()
    @State private var isShowingSplash = false
    
    // Alert state variables.
    @State private var isShowingAlert = false
    @State private var alertMessage: String = ""
    
    // Photo picker state variables.
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    // Sheet state variables.
    @State private var showAddNotificationView = false
    
    // Observed object to handle notification preview image.
    @ObservedObject var appState = AppState.shared
    
    // State variables for list preview image.
    @State private var showPreviewListImage = false
    @State private var previewListImage: Data? = nil
    @State private var previewListText: String? = nil
    
    // Define the body of the ContentView.
    var body: some View {
        
        // NavigationStack allows easy navigation handling.
        NavigationStack {
            
            // Check if the splash screen is currently being shown.
            if isShowingSplash {
                SplashView(isShowingSplash: $isShowingSplash)
            } else {
                // Main content area with a list of notifications.
                List {
                    ForEach(notifications, id: \.id) { notification in
                        
                        // Display different buttons based on the content of the notification.
                        if let imageData = notification.image, let imageText = notification.text, let uiImage = UIImage(data: imageData) {
                            // If there is both an image and text.
                            Button {
                                previewListImage = imageData
                                previewListText = imageText
                                showPreviewListImage = true
                            } label: {
                                // Display the image and text.
                                HStack(spacing: 8) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                    
                                    Text("\(notification.text ?? "") at \(formatTime(notification.notificationTime))")
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        else if let imageData = notification.image, let uiImage = UIImage(data: imageData) {
                            // If there is only an image.
                            Button {
                                previewListImage = imageData
                                previewListText = nil
                                showPreviewListImage = true
                            } label: {
                                // Display the image only.
                                HStack(spacing: 8) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                                    Text("\(formatTime(notification.notificationTime))")
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        else if let imageText = notification.text {
                            // If there is only text.
                            Button {
                                previewListText = imageText
                                previewListImage = nil
                                showPreviewListImage = true
                            } label: {
                                // Display the text only.
                                Text("\(notification.text ?? "") at \(formatTime(notification.notificationTime))")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete(perform: deleteNotification)
                }
                .navigationBarTitle("iProgramMe")
                .onAppear(perform: loadNotifications)
                .overlay {
                    // Display a message if there are no notifications.
                    if (notifications.isEmpty) {
                        Text("There's no notification. Try add one!")
                    }
                }
                
                // Sheet to add notifications.
                .sheet(isPresented: $showAddNotificationView, content: {
                    AddNotificationView(
                        selectedImage: $selectedImage,
                        selectedImageData: $selectedImageData,
                        newText: $newText, selectedTime: $selectedTime,
                        showAddNotificationSheet: $showAddNotificationView,
                        addNotification: addNotification
                    )
                })
                
                // Sheet to preview the image on the list.
                .sheet(isPresented: $showPreviewListImage, content: {
                    PreviewListImageView(
                        showPreviewListImage: $showPreviewListImage,
                        previewListImage: $previewListImage,
                        previewListText: $previewListText
                    )
                })
                
                // Sheet to show notification image.
                .sheet(isPresented: $appState.openPreviewSheet, content: {
                    NotificationImageView()
                })
                
                // Alert for displaying messages.
                .alert(isPresented: $isShowingAlert, content: {
                    Alert(title: Text(alertMessage))
                })
                
                // Toolbar with buttons for adding and deleting notifications.
                .toolbar(content: {
                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button {
                            // Reset form values.
                            resetFormValue()
                            
                            // Show the notification sheet.
                            showAddNotificationView.toggle()
                        } label: {
                            Label("Add new notification", systemImage: "plus")
                        }
                    }
                })
            }
        }
    }
    
    // Function to reset form values.
    func resetFormValue() {
        newText = ""
        selectedImage = nil
        selectedImageData = nil
        selectedTime = Date()
    }

    // Function to add a new notification.
    func addNotification() {
        // Instantiate a new notification data object.
        let newNotification = NotificationData(
            text: newText.isEmpty ? nil : newText,
            notificationTime: selectedTime,
            image: selectedImageData
        )

        // Schedule the notification.
        NotificationManager.scheduleNotification(notification: newNotification) {
            success, message in
            
            if success {
                // Notification scheduled successfully.
                // Append to the current state.
                notifications.append(newNotification)
                
                // To sort the pending notifications based on the time (ascending)
                // notifications = NotificationManager.sortNotificationsByTime(notifications)
                
                // Save the notification to local storage. 
                // saveNotifications()
            } else {
                // Notification scheduling failed.
                // Show an alert.
                alertMessage = message
                isShowingAlert.toggle()
            }
        }
    }

    // Function to delete a notification.
    func deleteNotification(at offsets: IndexSet) {
        // Get the index.
        guard let index = offsets.first else {return;}
        
        // Get the relevant notification ID to be removed from the schedule.
        let notificationId = notifications[index].id
        
        // Remove the notifications.
        notifications.remove(atOffsets: offsets)
        
        // Remove the notifications.
        NotificationManager.removeNotification(identifier: notificationId)
        
        // Commented out code that call function to save notifications.
        // saveNotifications()
    }

    // Function to format the time for display.
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Function to load notifications.
    func loadNotifications() {
        notifications = NotificationManager.loadNotifications()
    }

    // Commented out function to save notifications to local storage.
    // func saveNotifications() {
    //    NotificationManager.saveNotifications(notifications: notifications)
    // }
}



#Preview {
    ContentView()
}


*/

/*

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var notifications: [NotificationData] = []
    @State private var newText = ""
    @State private var selectedTime = Date()
    @State private var isShowingSplash = true // Added state for splash screen
    
    var body: some View {
        NavigationView {
            if isShowingSplash {
                SplashView(isShowingSplash: $isShowingSplash)
            } else {
               
                
                VStack {
                    
                    List {
                        ForEach(notifications) { notification in
                            Text("\(notification.text) at \(formatTime(notification.notificationTime))")
                        }
                        .onDelete(perform: deleteNotification)
                    }
                    
                    HStack {
                       
                        TextField("Enter text", text: $newText)
                        DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        
                        Button(action: addNotification) {
                            Text("Add")
                        }
                    }
                }
               
                .navigationBarTitle("iProgramMe")
               
            
                .onAppear(perform: loadNotifications)
                .onDisappear(perform: saveNotifications)
               
        }}}
    
    func addNotification() {
        if !newText.isEmpty && notifications.count < 10 {
            let newNotification = NotificationData(text: newText, notificationTime: selectedTime)
            notifications.append(newNotification)
            scheduleNotification(notification: newNotification) // Schedule the notification here
            newText = ""
        }
    }
    
    func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        // Remove the corresponding scheduled notifications here
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func scheduleNotification(notification: NotificationData) {
        let content = UNMutableNotificationContent()
        content.title = "iProgramMe"
        content.body = notification.text

        // Configure the notification trigger based on the selected time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: notification.notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create a unique identifier for the notification request
        let identifier = UUID().uuidString

        // Create the notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
    
    func loadNotifications() {
        // Load saved notifications here, e.g., from UserDefaults or a database
    }
    
    func saveNotifications() {
        // Save the notifications to persistent storage here
    }
}

struct NotificationData: Identifiable, Codable {
    let id = UUID()
    let text: String
    let notificationTime: Date
}




@available(iOS 15.0, *)
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
        return true
    }
}




*/

/*

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var notifications: [NotificationData] = []
    @State private var newText = ""
    @State private var selectedTime = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(notifications) { notification in
                        Text("\(notification.text) at \(formatTime(notification.notificationTime))")
                    }
                    .onDelete(perform: deleteNotification)
                }
                
                HStack {
                    TextField("Enter text", text: $newText)
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    
                    Button(action: addNotification) {
                        Text("Add")
                    }
                }
            }
            .navigationBarTitle("iProgramMe")
        }
        .onAppear(perform: loadNotifications)
        .onDisappear(perform: saveNotifications)
    }
    
    func addNotification() {
        if !newText.isEmpty && notifications.count < 10 {
            let newNotification = NotificationData(text: newText, notificationTime: selectedTime)
            notifications.append(newNotification)
            scheduleNotification(notification: newNotification) // Schedule the notification here
            newText = ""
        }
    }
    
    func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        // Remove the corresponding scheduled notifications here
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func scheduleNotification(notification: NotificationData) {
        let content = UNMutableNotificationContent()
        content.title = "iProgramMe"
        content.body = notification.text

        // Configure the notification trigger based on the selected time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: notification.notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create a unique identifier for the notification request
        let identifier = UUID().uuidString

        // Create the notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
    
    func loadNotifications() {
        // Load saved notifications here, e.g., from UserDefaults or a database
    }
    
    func saveNotifications() {
        // Save the notifications to persistent storage here
    }
}

struct NotificationData: Identifiable, Codable {
    let id = UUID()
    let text: String
    let notificationTime: Date
}




@available(iOS 15.0, *)
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
        return true
    }
}

*/

/*
import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var notifications: [NotificationData] = []
    @State private var newText = ""
    @State private var selectedTime = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(notifications) { notification in
                        Text("\(notification.text) at \(formatTime(notification.notificationTime))")
                    }
                    .onDelete(perform: deleteNotification)
                }
                
                HStack {
                    TextField("Enter text", text: $newText)
                    DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    
                    Button(action: addNotification) {
                        Text("Add")
                    }
                }
            }
            .navigationBarTitle("iProgramMe")
        }
        .onAppear(perform: loadNotifications)
        .onDisappear(perform: saveNotifications)
    }
    
    func addNotification() {
        if !newText.isEmpty && notifications.count < 10 {
            let newNotification = NotificationData(text: newText, notificationTime: selectedTime)
            notifications.append(newNotification)
            scheduleNotification(notification: newNotification) // Schedule the notification here
            newText = ""
        }
    }
    
    func deleteNotification(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
        // Remove the corresponding scheduled notifications here
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func scheduleNotification(notification: NotificationData) {
        let content = UNMutableNotificationContent()
        content.title = "iProgramMe"
        content.body = notification.text

        // Configure the notification trigger based on the selected time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: notification.notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Create a unique identifier for the notification request
        let identifier = UUID().uuidString

        // Create the notification request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully.")
            }
        }
    }
    
    func loadNotifications() {
        // Load saved notifications here, e.g., from UserDefaults or a database
    }
    
    func saveNotifications() {
        // Save the notifications to persistent storage here
    }
}

struct NotificationData: Identifiable, Codable {
    let id = UUID()
    let text: String
    let notificationTime: Date
}


struct iProgramMeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@available(iOS 15.0, *)
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                print("Notification permission granted.")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
        return true
    }
}

*/

/*
import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var notificationText = ""
    
    var body: some View {
        VStack {
            Text("iProgramMe")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter your text here", text: $notificationText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                scheduleNotifications()
            }) {
                Text("Schedule Notifications")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "iProgramMe"
        content.body = notificationText
        
        // Create a trigger to schedule daily notifications
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: DateComponents(hour: 19, minute: 16),
            repeats: true
        )
        
        // Create a notification request
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // Request authorization to send notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                // Schedule the notification
                UNUserNotificationCenter.current().add(request)
            } else if let error = error {
                print("Error requesting authorization: \(error)")
            }
        }
    }
}


 
 


import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
