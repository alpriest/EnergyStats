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
    @Published var foxESSTotal: FinanceAmount?
    private let approximationsCalculator: ApproximationsCalculator

    init(configManager: ConfigManaging, networking: Networking) {
        self.networking = networking
        self.configManager = configManager
        self.approximationsCalculator = ApproximationsCalculator(configManager: configManager, networking: networking)
    }

    func load() {
        guard approximationsViewModel == nil else { return }
        guard let currentDevice = configManager.currentDevice.value else { return }

        Task { @MainActor in
            isLoading = true
            let foxEarnings = try await self.networking.fetchEarnings(deviceID: currentDevice.deviceID)
            foxESSTotal = FinanceAmount(title: .total, amount: foxEarnings.cumulate.earnings, currencySymbol: foxEarnings.currencySymbol)
            let totals = try await fetchAllYears(device: currentDevice)

            self.approximationsViewModel = makeApproximationsViewModel(totals: totals, response: foxEarnings)

            isLoading = false
        }
    }

    private func fetchAllYears(device: Device) async throws -> [ReportVariable: Double] {
        var totals = [ReportVariable: Double]()

        totals = try await fetchYear(2023, device: device, totals: totals)
        totals = try await fetchYear(2022, device: device, totals: totals)

        return totals
    }

    private func fetchYear(_ year: Int, device: Device, totals: [ReportVariable: Double]) async throws -> [ReportVariable: Double] {
        let reportVariables = [ReportVariable.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads]
        let reports = try await networking.fetchReport(deviceID: device.deviceID,
                                                       variables: reportVariables,
                                                       queryDate: QueryDate(year: year, month: nil, day: nil),
                                                       reportType: .year)

        var totals = totals
        reports.forEach { reportResponse in
            guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

            totals[reportVariable] = (totals[reportVariable] ?? 0) + reportResponse.data.map { abs($0.value) }.reduce(0.0, +)
        }

        return totals
    }

    private func makeApproximationsViewModel(
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

        return approximationsCalculator.calculateApproximations(grid: grid, feedIn: feedIn, loads: loads, batteryCharge: batteryCharge, batteryDischarge: batteryDischarge, earnings: response)
    }
}
