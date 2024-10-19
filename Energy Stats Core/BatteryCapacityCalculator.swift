//
//  BatteryCapacityCalculator.swift
//  Energy Stats
//
//  Created by Alistair Priest on 21/09/2022.
//

import Foundation

public class BatteryCapacityCalculator {
    private let capacityW: Double
    private let formatter = RelativeDateTimeFormatter()
    private let minimumSOC: Double
    private let percentageConsideredFull = 98.75
    private let bundle: Bundle

    public init(capacityW: Int, minimumSOC: Double, bundle: Bundle = .main) {
        self.capacityW = Double(capacityW)
        self.minimumSOC = minimumSOC
        self.bundle = bundle
    }

    private var minimumCharge: Double {
        capacityW * minimumSOC
    }

    public func batteryChargeStatusDescription(batteryChargePowerkW: Double, batteryStateOfCharge: Double) -> String? {
        guard abs(batteryChargePowerkW) > 0 else { return nil }

        let currentEstimatedCharge = capacityW * batteryStateOfCharge

        if batteryChargePowerkW > 0 { // battery charging
            let capacityRemaining = capacityW - currentEstimatedCharge
            let minsToFullCharge = (capacityRemaining / (batteryChargePowerkW * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsToFullCharge)

            return String(key: .full, bundle: bundle) + " \(duration)"
        } else { // battery discharging
            let chargeRemaining = currentEstimatedCharge - minimumCharge
            let minsUntilEmpty = (chargeRemaining / abs(batteryChargePowerkW * 1000.0)) * 60 * 60
            let duration = formatter.localizedString(fromTimeInterval: minsUntilEmpty)

            return String(key: .empty, bundle: bundle) + " \(duration)"
        }
    }

    public func currentEstimatedChargeAmountWh(batteryStateOfCharge: Double, includeUnusableCapacity: Bool = true) -> Double {
        (capacityW * batteryStateOfCharge) - (includeUnusableCapacity ? 0 : minimumCharge)
    }

    public func effectiveBatteryStateOfCharge(batteryStateOfCharge: Double, includeUnusableCapacity: Bool = true) -> Double {
        guard batteryStateOfCharge <= percentageConsideredFull else { return 0.99 }

        let deduction = includeUnusableCapacity ? 0 : minimumSOC
        return ((batteryStateOfCharge - deduction) / (1 - deduction)).rounded(decimalPlaces: 2)
    }
}
