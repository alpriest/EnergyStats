//
//  CoreBusReceiver.swift
//  Energy Stats
//
//  Created by Alistair Priest on 19/09/2025.
//

import Energy_Stats_Core
import FirebaseAnalytics
import Foundation

enum CoreBusReceiver {
    static func observeAnalyticsEvent() {
        NotificationCenter.default.addObserver(
            forName: .unexpectedServerData,
            object: nil,
            queue: .main
        ) { note in
            guard
                let name = note.userInfo?[CoreBus.Keys.name] as? String
            else { return }

            let params = note.userInfo?[CoreBus.Keys.params] as? [String: Any]
            Analytics.logEvent(name, parameters: params)
        }
    }
}
