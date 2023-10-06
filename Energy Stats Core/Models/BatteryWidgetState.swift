//
//  BatteryWidgetState.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 26/09/2023.
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
public class BatteryWidgetState {
    public let batterySOC: Int
    public let lastUpdated: Date
    public let chargeStatusDescription: String?

    public init(batterySOC: Int, lastUpdated: Date = Date(), chargeStatusDescription: String?) {
        self.batterySOC = batterySOC
        self.lastUpdated = Date()
        self.chargeStatusDescription = chargeStatusDescription
    }   

    public static func empty() -> BatteryWidgetState {
        BatteryWidgetState(batterySOC: 0, lastUpdated: .distantPast, chargeStatusDescription: nil)
    }
}

@available(iOS 17.0, *)
extension BatteryWidgetState {
    static var preview: BatteryWidgetState {
        BatteryWidgetState(batterySOC: 55, lastUpdated: .now, chargeStatusDescription: "Full in 23 minutes")
    }
}
