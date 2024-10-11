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
    public var batterySOC: Int
    public var lastUpdated: Date
    public var chargeStatusDescription: String?
    public var batteryPower: Double?

    public init(batterySOC: Int, lastUpdated: Date = Date(), chargeStatusDescription: String?, batteryPower: Double) {
        self.batterySOC = batterySOC
        self.lastUpdated = Date()
        self.chargeStatusDescription = chargeStatusDescription
        self.batteryPower = batteryPower
    }

    public static func empty() -> BatteryWidgetState {
        BatteryWidgetState(batterySOC: 0, lastUpdated: .distantPast, chargeStatusDescription: nil, batteryPower: 0)
    }

    static var preview: BatteryWidgetState {
        BatteryWidgetState(batterySOC: 55, lastUpdated: .now, chargeStatusDescription: "Full in 23 minutes", batteryPower: 2.2)
    }
}

@available(iOS 17.0, *)
@Model
public class StatsWidgetState {
    public var lastUpdated: Date
    public var home: [Double]
    public var gridImport: [Double]
    public var gridExport: [Double]
    public var batteryCharge: [Double]
    public var batteryDischarge: [Double]

    public init(
        lastUpdated: Date = Date(),
        home: [Double],
        gridExport: [Double],
        gridImport: [Double],
        batteryCharge: [Double],
        batteryDischarge: [Double]
    ) {
        self.lastUpdated = lastUpdated
        self.home = home
        self.gridExport = gridExport
        self.gridImport = gridImport
        self.batteryCharge = batteryCharge
        self.batteryDischarge = batteryDischarge
    }

    public static func empty() -> StatsWidgetState {
        StatsWidgetState(home: [0], gridExport: [0], gridImport: [0], batteryCharge: [0], batteryDischarge: [0])
    }

    static var preview: StatsWidgetState {
        StatsWidgetState(
            home: [0.0, 0.5, 0.9, 1.2, 1.5, 1.8, 1.3, 0.7, 0.3, 1.0, 1.6, 0.2],
            gridExport: [1.0, 1.2, 1.8, 0.4, 0.9, 0.7, 1.3, 1.5, 0.2, 1.1, 1.9, 0.6],
            gridImport: [2.0, 1.9, 1.8, 0.3, 0.5, 0.7, 1.0, 1.2, 1.7, 0.8, 1.5, 0.6],
            batteryCharge: [2.4, 1.6, 0.9, 0.2, 1.3, 1.9, 0.7, 1.1, 0.5, 1.8, 1.0, 0.4],
            batteryDischarge: [0.9, 0.2, 1.3, 1.5, 0.7, 0.8, 1.6, 0.3, 0.6, 1.9, 0.4, 1.2]
        )
    }
}
