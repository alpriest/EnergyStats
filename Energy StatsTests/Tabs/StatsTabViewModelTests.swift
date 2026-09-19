//
//  StatsTabViewModelTests.swift
//  Energy StatsTests
//

@testable import Energy_Stats
import Energy_Stats_Core
import Foundation
import Testing

struct StatsTabViewModelTests {
    let calculator: StatsDerivedDataCalculator

    init() {
        let config = MockConfig()
        let networking = MockNetworking(dateProvider: {
            Date(timeIntervalSince1970: 1_669_146_973)
        })

        let appSettingsStore = AppSettingsStoreFactory.make()
        appSettingsStore.update(.mock())

        let configManager = ConfigManager(
            networking: networking,
            config: config,
            appSettingsStore: appSettingsStore,
            keychainStore: MockKeychainStore()
        )

        calculator = StatsDerivedDataCalculator(
            approximationsCalculator: ApproximationsCalculator(
                configManager: configManager,
                networking: networking
            )
        )
    }

    @Test
    func `Calculates self sufficiency graph values`() {
        let date = Date(timeIntervalSince1970: 1_669_146_973)
        let input = values(
            date: date,
            grid: 2,
            feedIn: 0,
            loads: 10,
            batteryCharge: 0,
            batteryDischarge: 0,
            solar: 10
        )

        let result = calculator.calculateSelfSufficiencyAcrossTimePeriod(input, mode: .absolute)

        #expect(result.count == 1)
        #expect(result.first?.type == .selfSufficiency)
        #expect(result.first?.date == date)
        #expect(result.first?.graphValue == 0.8)
        #expect(result.first?.displayValue == 0.8)
    }

    @Test
    func `Calculates inverter consumption graph values and total`() {
        let date = Date(timeIntervalSince1970: 1_669_146_973)
        let input = values(
            date: date,
            grid: 2,
            feedIn: 0,
            loads: 10,
            batteryCharge: 0,
            batteryDischarge: 0,
            solar: 10
        )

        let result = calculator.calculateInverterConsumptionAcrossTimePeriod(input)

        #expect(result.values.count == 1)
        #expect(result.values.first?.type == .inverterConsumption)
        #expect(result.values.first?.date == date)
        #expect(result.values.first?.graphValue == 2)
        #expect(result.values.first?.displayValue == 2)
        #expect(result.total == 2)
    }

    private func values(
        date: Date,
        grid: Double,
        feedIn: Double,
        loads: Double,
        batteryCharge: Double,
        batteryDischarge: Double,
        solar: Double
    ) -> [StatsGraphValue] {
        [
            StatsGraphValue(type: .gridConsumption, date: date, graphValue: grid, displayValue: grid),
            StatsGraphValue(type: .feedIn, date: date, graphValue: feedIn, displayValue: feedIn),
            StatsGraphValue(type: .loads, date: date, graphValue: loads, displayValue: loads),
            StatsGraphValue(type: .chargeEnergyToTal, date: date, graphValue: batteryCharge, displayValue: batteryCharge),
            StatsGraphValue(type: .dischargeEnergyToTal, date: date, graphValue: batteryDischarge, displayValue: batteryDischarge),
            StatsGraphValue(type: .pvEnergyTotal, date: date, graphValue: solar, displayValue: solar)
        ]
    }
}
