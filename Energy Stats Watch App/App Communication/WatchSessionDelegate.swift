//
//  WatchSessionDelegate.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 05/05/2024.
//

import Foundation
import WatchConnectivity

class WatchSessionDelegate: NSObject, WCSessionDelegate {
    var config: WatchConfigManager?

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        print("AWP", "Received data")
        if let value = userInfo["batteryCapacity"] as? String {
            print("AWP", "Setting batteryCapacity", value)
            config?.batteryCapacity = value
        }

        if let value = userInfo["shouldInvertCT2"] as? Bool {
            print("AWP", "Setting shouldInvertCT2", value)
            config?.shouldInvertCT2 = value
        }

        if let value = userInfo["shouldCombineCT2WithPVPower"] as? Bool {
            print("AWP", "Setting shouldCombineCT2WithPVPower", value)
            config?.shouldCombineCT2WithPVPower = value
        }

        if let value = userInfo["showUsableBatteryOnly"] as? Bool {
            print("AWP", "Setting showUsableBatteryOnly", value)
            config?.showUsableBatteryOnly = value
        }
    }
}
