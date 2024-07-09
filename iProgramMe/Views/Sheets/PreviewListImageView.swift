//
//  PreviewListImageView.swift
//  iProgramMe
//
//  Created by Jonathan Lee on 29/12/23.
//

import SwiftUI

// SwiftUI View for previewing an image and text
struct PreviewListImageView: View {
    @Binding var showPreviewListImage: Bool
    @Binding var previewListImage: Data?
    @Binding var previewListText: String?
    
    var body: some View {
        // Navigation stack for navigation-related functionality
        NavigationStack {
            // Scrollable content
            ScrollView {
                // Vertical stack to organize content
                VStack(spacing: 8) {
                    Text("iProgramMe")
                        .font(.headline)
                        .monospaced()
                    // If there is image data, display the image
                    if let imageData = previewListImage, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                    
                    // If there is body text, display the text
                    if let bodyText = previewListText {
                        Text(bodyText)
                    }
                }
            }
            // Toolbar for additional actions
            .toolbar(content: {
                // Group of items in the toolbar, placed on the confirmation action side
                ToolbarItemGroup(placement: .confirmationAction, content: {
                    // Button to close the preview
                    Button {
                        showPreviewListImage.toggle()
                    } label: {
                        Text("Close")
                    }
                })
            })
        }
    }
}

