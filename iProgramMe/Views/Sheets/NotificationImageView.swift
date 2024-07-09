//
//  NotificationImageView.swift
//  iProgramMe
//
//  Created by Jonathan Lee on 29/12/23.
//

import SwiftUI

// SwiftUI View for handling notification preview images
struct NotificationImageView: View {
    // ObservedObject to manage app state
    @ObservedObject var appState = AppState.shared
    
    // State variable to store the preview notification image
    @State private var previewNotificationImage: Data? = nil
    
    var body: some View {
        // Navigation stack for navigation-related functionality
        NavigationStack {
            // Scrollable content
            ScrollView {
                
                Text("iProgramMe")
                    .font(.headline)
                    .monospaced()
                // If there is an image URL in app state, attempt to load and display the image
                if let imageURL = appState.imageURL, imageURL.startAccessingSecurityScopedResource(), let uiImage = UIImage(contentsOfFile: imageURL.path()) {
                    // Vertical stack to organize content
                    VStack(spacing: 8) {
                        
                        // Display a message along with the image
//                        Text("iProgramMe")
                        
                        // Display the image
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    .onDisappear {
                        // Stop accessing the security-scoped resource when the view disappears
                        imageURL.stopAccessingSecurityScopedResource()
                    }
                    
                }
                
                // If there is body text in app state, display the text
                if let bodyText = appState.bodyText {
                    // Display the body text
                    Text(bodyText)
                }

                
            }
            // Toolbar for additional actions
            .toolbar(content: {
                // Group of items in the toolbar, placed on the confirmation action side
                ToolbarItemGroup(placement: .confirmationAction, content: {
                    // Button to close the preview sheet
                    Button {
                        appState.openPreviewSheet.toggle()
                    } label: {
                        Text("Close")
                    }
                })
            })
        }
    }
}
