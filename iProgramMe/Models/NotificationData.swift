//
//  NotificationData.swift
//  iProgramMe
//
//  Created by Jonathan Lee on 29/12/23.
//

import Foundation

struct NotificationData: Identifiable, Codable {
    var id = ProcessInfo.processInfo.globallyUniqueString
    let text: String?
    let notificationTime: Date
    let image: Data?
}
