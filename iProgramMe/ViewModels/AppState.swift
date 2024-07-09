//
//  AppState.swift
//  iProgramMe
//
//  Created by Jonathan Lee on 29/12/23.
//

import Foundation

// Define a class named AppState that conforms to the ObservableObject protocol.
class AppState: ObservableObject {
    // Initialize the AppState with an openPreviewSheet flag and optional imageURL.
    init(openPreviewSheet: Bool) {
        // Set the openPreviewSheet property to the provided value.
        self.openPreviewSheet = openPreviewSheet
    }
    
    // Declare a shared instance of AppState with a default value of openPreviewSheet set to false.
    static let shared = AppState(openPreviewSheet: false)
    
    // Declare a Published property openPreviewSheet of type Bool to make it observable.
    @Published var openPreviewSheet: Bool
    
    // Declare a Published property imageURL of type URL? to make it observable.
    @Published var imageURL: URL?
    
    // Declare a Published property bodyText of type String? to make it observable.
    @Published var bodyText: String?
}
