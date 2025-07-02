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
    public var pvEnergy: [Double]
    public var totalHome: Double
    public var totalGridImport: Double
    public var totalGridExport: Double
    public var totalBatteryCharge: Double?
    public var totalBatteryDischarge: Double?
    public var totalPVEnergy: Double?

    public init(
        lastUpdated: Date = Date(),
        home: [Double],
        gridExport: [Double],
        gridImport: [Double],
        batteryCharge: [Double],
        batteryDischarge: [Double],
        pvEnergy: [Double],
        totalHome: Double,
        totalGridImport: Double,
        totalGridExport: Double,
        totalBatteryCharge: Double?,
        totalBatteryDischarge: Double?,
        totalPVEnergy: Double?
    ) {
        self.lastUpdated = lastUpdated
        self.home = home
        self.gridExport = gridExport
        self.gridImport = gridImport
        self.batteryCharge = batteryCharge
        self.batteryDischarge = batteryDischarge
        self.pvEnergy = pvEnergy
        self.totalHome = totalHome
        self.totalGridImport = totalGridImport
        self.totalGridExport = totalGridExport
        self.totalBatteryCharge = totalBatteryCharge
        self.totalBatteryDischarge = totalBatteryDischarge
        self.totalPVEnergy = totalPVEnergy
    }

    public static func empty() -> StatsWidgetState {
        StatsWidgetState(
            home: [0],
            gridExport: [0],
            gridImport: [0],
            batteryCharge: [0],
            batteryDischarge: [0],
            pvEnergy: [0],
            totalHome: 0,
            totalGridImport: 0,
            totalGridExport: 0,
            totalBatteryCharge: nil,
            totalBatteryDischarge: nil,
            totalPVEnergy: nil
        )
    }

    static var preview: StatsWidgetState {
        let homeValues = [0.0, 0.5, 0.9, 1.2, 1.5, 1.8, 1.3, 0.7, 0.3, 1.0, 1.6, 0.2]
        let gridExportValues = [1.0, 1.2, 1.8, 0.4, 0.9, 0.7, 1.3, 1.5, 0.2, 1.1, 1.9, 0.6]
        let gridImportValues = [2.0, 1.9, 1.8, 0.3, 0.5, 0.7, 1.0, 1.2, 1.7, 0.8, 1.5, 0.6]
        let batteryChargeValues = [2.4, 1.6, 0.9, 0.2, 1.3, 1.9, 0.7, 1.1, 0.5, 1.8, 1.0, 0.4]
        let batteryDischargeValues = [0.9, 0.2, 1.3, 1.5, 0.7, 0.8, 1.6, 0.3, 0.6, 1.9, 0.4, 1.2]
        let pvEnergyValues = [0.0, 0.5, 0.9, 1.2, 1.5, 1.8, 1.3, 0.7, 0.3, 1.0, 1.6, 0.2]

        return StatsWidgetState(
            home: homeValues,
            gridExport: gridExportValues,
            gridImport: gridImportValues,
            batteryCharge: batteryChargeValues,
            batteryDischarge: batteryDischargeValues,
            pvEnergy: pvEnergyValues,
            totalHome: homeValues.reduce(0, +),
            totalGridImport: gridImportValues.reduce(0, +),
            totalGridExport: gridExportValues.reduce(0, +),
            totalBatteryCharge: batteryChargeValues.reduce(0, +),
            totalBatteryDischarge: batteryDischargeValues.reduce(0, +),
            totalPVEnergy: pvEnergyValues.reduce(0, +)
        )
    }
}
