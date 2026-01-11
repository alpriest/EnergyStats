//
//  WatchSessionDelegate.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/05/2024.
//

import Energy_Stats_Core
import Foundation
#if canImport(WatchConnectivity)
import WatchConnectivity

class PhoneToWatchSessionDelegate: NSObject, WCSessionDelegate {
    var config: ConfigManaging?
    var userManager: UserManager?

    // Build the userInfo payload from current config
    private func currentUserInfo(apiKey: String?, isLoggedIn: Bool) -> [String: Any]? {
        guard let config else { return nil }

        var userInfo: [String: Any] = [
            "batteryCapacity": config.batteryCapacity,
            "shouldInvertCT2": config.shouldInvertCT2,
            "shouldCombineCT2WithPVPower": config.shouldCombineCT2WithPVPower,
            "showUsableBatteryOnly": config.showUsableBatteryOnly,
            "showGridTotalsOnPowerFlow": config.showGridTotalsOnPowerFlow,
            "minSOC": config.minSOC,
            "solarDefinitionsBreakPoint1": config.solarDefinitions.breakPoint1,
            "solarDefinitionsBreakPoint2": config.solarDefinitions.breakPoint2,
            "solarDefinitionsBreakPoint3": config.solarDefinitions.breakPoint3,
            "loggedIn": isLoggedIn
        ]

        if let selectedDeviceSN = config.selectedDeviceSN {
            userInfo["deviceSN"] = selectedDeviceSN
        }
        
        if let apiKey {
            userInfo["apiKey"] = apiKey
        }

        return userInfo
    }

    /// Send current configuration to the paired watch on demand.
    /// Safely chooses `transferUserInfo` if the session is activated, and falls back to queuing when possible.
    func sendCurrentConfig(apiKey: String?, isLoggedIn: Bool) {
        guard let userInfo = currentUserInfo(apiKey: apiKey, isLoggedIn: isLoggedIn) else { return }
        let session = WCSession.default
        // Ensure the session is at least activated before attempting transfer.
        if WCSession.isSupported() {
            if session.activationState == .activated {
                session.transferUserInfo(userInfo)
            } else {
                // Activate and send once activation completes.
                session.activate()
            }
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {}
}
#endif
