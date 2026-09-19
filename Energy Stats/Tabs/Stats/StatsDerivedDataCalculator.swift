//
//  StatsDerivedDataCalculator.swift
//  Energy Stats
//

import Energy_Stats_Core
import Foundation

struct InverterConsumptionResult {
    let values: [StatsGraphValue]
    let total: Double
}

struct StatsDerivedDataCalculator {
    let approximationsCalculator: ApproximationsCalculator

    func calculateSelfSufficiencyAcrossTimePeriod(
        _ rawData: [StatsGraphValue],
        mode: SelfSufficiencyEstimateMode
    ) -> [StatsGraphValue] {
        let dates = Set(rawData.map(\.date))
        var selfSufficiencyAtDateTime: [Date: Double] = [:]

        for date in dates {
            let valuesAtTime = ValuesAtTime(values: rawData.filter { $0.date == date })

            if let grid = valuesAtTime.values.first(where: { $0.type == .gridConsumption })?.graphValue,
               let feedIn = valuesAtTime.values.first(where: { $0.type == .feedIn })?.graphValue,
               let loads = valuesAtTime.values.first(where: { $0.type == .loads })?.graphValue,
               let batteryCharge = valuesAtTime.values.first(where: { $0.type == .chargeEnergyToTal })?.graphValue,
               let batteryDischarge = valuesAtTime.values.first(where: { $0.type == .dischargeEnergyToTal })?.graphValue,
               let solar = valuesAtTime.values.first(where: { $0.type == .pvEnergyTotal })?.graphValue
            {
                let approximations = approximationsCalculator.calculateApproximations(
                    grid: grid,
                    feedIn: feedIn,
                    loads: loads,
                    batteryCharge: batteryCharge,
                    batteryDischarge: batteryDischarge,
                    solar: solar
                )

                let value: Double?

                switch mode {
                case .absolute:
                    value = approximations.absoluteSelfSufficiencyEstimateValue
                case .net:
                    value = approximations.netSelfSufficiencyEstimateValue
                default:
                    value = nil
                }

                if let value {
                    selfSufficiencyAtDateTime[date] = value
                }
            }
        }

        return selfSufficiencyAtDateTime
            .map {
                StatsGraphValue(
                    type: .selfSufficiency,
                    date: $0.key,
                    graphValue: $0.value,
                    displayValue: $0.value
                )
            }
            .sorted(by: { $1.date > $0.date })
            .filter { $0.date <= Date.now }
    }

    func calculateInverterConsumptionAcrossTimePeriod(
        _ rawData: [StatsGraphValue]
    ) -> InverterConsumptionResult {
        let dates = Set(rawData.map(\.date))
        var inverterConsumptionAtDateTime: [Date: Double] = [:]

        for date in dates {
            let valuesAtTime = ValuesAtTime(values: rawData.filter { $0.date == date })

            if let grid = valuesAtTime.values.first(where: { $0.type == .gridConsumption })?.graphValue,
               let feedIn = valuesAtTime.values.first(where: { $0.type == .feedIn })?.graphValue,
               let loads = valuesAtTime.values.first(where: { $0.type == .loads })?.graphValue,
               let batteryCharge = valuesAtTime.values.first(where: { $0.type == .chargeEnergyToTal })?.graphValue,
               let batteryDischarge = valuesAtTime.values.first(where: { $0.type == .dischargeEnergyToTal })?.graphValue,
               let solar = valuesAtTime.values.first(where: { $0.type == .pvEnergyTotal })?.graphValue
            {
                inverterConsumptionAtDateTime[date] = Swift.max(
                    (solar + grid + batteryDischarge) - (feedIn + batteryCharge + loads),
                    0
                )
            }
        }

        let values = inverterConsumptionAtDateTime
            .map {
                StatsGraphValue(
                    type: .inverterConsumption,
                    date: $0.key,
                    graphValue: $0.value,
                    displayValue: $0.value
                )
            }
            .sorted(by: { $1.date > $0.date })
            .filter { $0.date <= Date.now }

        return InverterConsumptionResult(
            values: values,
            total: inverterConsumptionAtDateTime.values.reduce(0, +)
        )
    }
}
