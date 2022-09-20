//
//  Notifications.swift
//  Energy Stats
//
//  Created by Alistair Priest on 20/09/2022.
//

import SwiftUI

extension View {
    func onNotification<T>(named name: Notification.Name, perform action: @escaping (T) -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: name)) { notification in
            guard let value = notification.object as? T else { return }
            action(value)
        }
    }
}
