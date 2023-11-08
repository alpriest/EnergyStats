//
//  SummaryTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/11/2023.
//

import Energy_Stats_Core
import Foundation

class SummaryTabViewModel: ObservableObject {
    private let networking: Networking
    private let configManager: ConfigManaging
    @Published var isLoading = false
    @Published var totalSaving: String = ""
    @Published var exportIncome: String = ""
    @Published var gridImportAvoided: String = ""
    @Published var approximationsViewModel: ApproximationsViewModel? = nil
    private let approximationsCalculator: ApproximationsCalculator

    init(configManager: ConfigManaging, networking: Networking) {
        self.networking = networking
        self.configManager = configManager
        self.approximationsCalculator = ApproximationsCalculator(configManager: configManager, networking: networking)
    }

    func load() {
        if let currentDevice = configManager.currentDevice.value {
            Task { @MainActor in
                isLoading = true
                let reportVariables = [ReportVariable.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads]
                let reports = try await self.networking.fetchReport(deviceID: currentDevice.deviceID,
                                                                    variables: reportVariables,
                                                                    queryDate: QueryDate(year: 2023, month: nil, day: nil),
                                                                    reportType: .year)
                let earnings = try await self.networking.fetchEarnings(deviceID: currentDevice.deviceID)
                var totals = [ReportVariable: Double]()
                reports.forEach { reportResponse in
                    guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

                    totals[reportVariable] = reportResponse.data.map { abs($0.value) }.reduce(0.0, +)
                }

                self.approximationsViewModel = makeEarningsViewModel(totals: totals, response: earnings)

                isLoading = false
            }
        }
    }

    private func makeEarningsViewModel(
        totals: [ReportVariable: Double],
        response: EarningsResponse
    ) -> ApproximationsViewModel? {
        guard let grid = totals[ReportVariable.gridConsumption],
              let feedIn = totals[ReportVariable.feedIn],
              let loads = totals[ReportVariable.loads],
              let batteryCharge = totals[ReportVariable.chargeEnergyToTal],
              let batteryDischarge = totals[ReportVariable.dischargeEnergyToTal]
        else {
            return nil
        }

        return approximationsCalculator.calculateApproximations(grid: grid, feedIn: feedIn, loads: loads, batteryCharge: batteryCharge, batteryDischarge: batteryDischarge)
    }
}
