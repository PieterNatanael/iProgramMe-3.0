//
//  NotificationAttachmentExtension.swift
//  iProgramMe
//
//  Created by Jonathan Lee on 29/12/23.
//

import Foundation
import SwiftUI

// Extension on UNNotificationAttachment to create a temporary image file and return the attachment
extension UNNotificationAttachment {
    // Create a notification attachment with the specified identifier, image data, and options
    static func create(identifier: String, image: Data, options: [NSObject: AnyObject]?) throws -> UNNotificationAttachment? {
        // Setup the required variables
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)

        do {
            // Create a directory in the temporary folder
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)

            // Create an image identifier (name)
            let imageFileIdentifier = identifier + ".jpeg"

            // Get the full path for the temporary file
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)

            // Get image data from the provided Data object
            guard let imageData = UIImage(data: image)?.jpegData(compressionQuality: 1.0) else {
                // Throw an error if image data creation fails
                throw NotificationError.imageDataCreationFailed(message: "Failed to create image data.")
            }

            // If the image size exceeds 10 MB (based on documentation)
            if imageData.count / Int(1000000) > 10 {
                // Throw an error if the image size exceeds the limit of 10 MB
                throw NotificationError.imageSizeExceedsLimit(message: "Image size exceeds the limit of 10MB.")
            } else {
                // Write the image data to the temporary directory
                try imageData.write(to: fileURL)

                // Return the attachment
                let imageAttachment = try UNNotificationAttachment(identifier: imageFileIdentifier, url: fileURL, options: options)
                return imageAttachment
            }
        } catch {
            // Print an error message if any error occurs during the process
            print("error " + error.localizedDescription)
            // Throw an error if writing to the file fails
            throw NotificationError.fileWriteFailed(message: "Image can't be stored. Try again.")
        }
    }
}

// Enum for custom notification-related errors
enum NotificationError: Error {
    case imageDataCreationFailed(message: String)
    case imageSizeExceedsLimit(message: String)
    case fileWriteFailed(message: String)
}

