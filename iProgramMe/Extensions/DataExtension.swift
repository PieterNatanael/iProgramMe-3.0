//
//  DataExtension.swift
//  iProgramMe
//
//  Created by Jonathan Lee on 29/12/23.
//

import Foundation

// Extension on Data to initialize it from a given URL
extension Data {
    init?(from url: URL?) {
        // Ensure that the URL is not nil
        guard let url = url else {
            // Return nil if the URL is nil
            return nil
        }

        do {
            // Try to initialize Data by loading content from the specified URL
            self = try Data(contentsOf: url)
        } catch {
            // Print an error message if there is an issue loading data from the URL
            print("Error loading data from URL: \(error)")
            // Return nil in case of an error
            return nil
        }
    }
}
