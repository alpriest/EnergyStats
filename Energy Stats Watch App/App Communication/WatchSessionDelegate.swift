//
//  WatchSessionDelegate.swift
//  Energy Stats Watch App
//
//  Created by Alistair Priest on 05/05/2024.
//

import Energy_Stats_Core
import Foundation
import WatchConnectivity

class WatchToPhoneSessionDelegate: NSObject, WCSessionDelegate {
    var config: WatchConfigManager?

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {}

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        config?.applyUpdatesThenNotify {
            $0.apiKey = userInfo["apiKey"] as? String
            
            if let value = userInfo["deviceSN"] as? String {
                $0.deviceSN = value
            }
            
            if let value = userInfo["loggedIn"] as? Bool, !value {
                $0.apiKey = nil
                $0.deviceSN = nil
            }
            
            if let value = userInfo["batteryCapacity"] as? String {
                $0.batteryCapacity = value
            }
            
            if let value = userInfo["shouldInvertCT2"] as? Bool {
                $0.shouldInvertCT2 = value
            }
            
            if let value = userInfo["minSOC"] as? Double {
                $0.minSOC = value
            }
            
            if let value = userInfo["shouldCombineCT2WithPVPower"] as? Bool {
                $0.shouldCombineCT2WithPVPower = value
            }
            
            if let value = userInfo["showUsableBatteryOnly"] as? Bool {
                $0.showUsableBatteryOnly = value
            }
            
            if let value = userInfo["showGridTotalsOnPowerFlow"] as? Bool {
                $0.showGridTotalsOnPowerFlow = value
            }
            
            if let breakpoint1 = userInfo["solarDefinitionsBreakpoint1"] as? Double,
               let breakpoint2 = userInfo["solarDefinitionsBreakpoint2"] as? Double,
               let breakpoint3 = userInfo["solarDefinitionsBreakpoint3"] as? Double {
                $0.solarDefinitions = SolarRangeDefinitions(breakPoint1: breakpoint1, breakPoint2: breakpoint2, breakPoint3: breakpoint3)
            }
        }
    }
    
    func activateIfNeeded() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        if session.delegate == nil {
            session.delegate = self
        }
        if session.activationState != .activated {
            session.activate()
        }
    }
}
