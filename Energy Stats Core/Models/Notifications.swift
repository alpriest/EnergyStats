//
//  Notifications.swift
//  Energy Stats
//
//  Created by Alistair Priest on 05/11/2024.
//

import Foundation

public extension Notification.Name {
    static let deviceIsOffline = Notification.Name("deviceIsOffline")
    static let unexpectedServerData = Notification.Name("unexpectedServerData")
}
