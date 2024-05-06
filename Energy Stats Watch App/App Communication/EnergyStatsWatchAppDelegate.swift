//
//  EnergyStatsWatchAppDelegate.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 05/05/2024.
//

import WatchConnectivity
import WatchKit

class EnergyStatsWatchAppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidBecomeActive() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = Energy_Stats_Watch_App.delegate
            session.activate()
        }
    }
}
