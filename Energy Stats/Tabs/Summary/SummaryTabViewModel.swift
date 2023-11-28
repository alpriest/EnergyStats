//
//  SummaryTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/11/2023.
//

import Energy_Stats_Core
import Foundation

class SummaryTabViewModel: ObservableObject {
    private let networking: FoxESSNetworking
    private let configManager: ConfigManaging
    @Published var isLoading = false
    @Published var approximationsViewModel: ApproximationsViewModel? = nil
    @Published var oldestDataDate: String = ""
    let currencySymbol: String
    private let approximationsCalculator: ApproximationsCalculator

    init(configManager: ConfigManaging, networking: FoxESSNetworking) {
        self.networking = networking
        self.configManager = configManager
        self.approximationsCalculator = ApproximationsCalculator(configManager: configManager, networking: networking)
        currencySymbol = self.configManager.currencySymbol
    }

    func load() {
        guard approximationsViewModel == nil else { return }
        guard let currentDevice = configManager.currentDevice.value else { return }

        Task { @MainActor in
            isLoading = true
            let foxEarnings = try await self.networking.fetchEarnings(deviceID: currentDevice.deviceID)
            let totals = try await fetchAllYears(device: currentDevice)

            self.approximationsViewModel = makeApproximationsViewModel(totals: totals, response: foxEarnings)

            isLoading = false
        }
    }

    private func fetchAllYears(device: Device) async throws -> [ReportVariable: Double] {
        var totals = [ReportVariable: Double]()
        let maxYears = 20
        var hasFinished = false

        let currentYear = Calendar.current.component(.year, from: Date())
        for year in (currentYear - maxYears ... currentYear).reversed() {
            if hasFinished {
                break
            }

            do {
                let (yearlyTotals, emptyMonth) = try await fetchYear(year, device: device)

                if let emptyMonth {
                    await MainActor.run {
                        var components = DateComponents()
                        components.year = year
                        components.month = emptyMonth
                        components.day = 1
                        if let date = Calendar.current.date(from: components) {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MMMM YYYY"
                            oldestDataDate = dateFormatter.string(from: date)
                        } else {
                            oldestDataDate = "\(emptyMonth) \(year)"
                        }
                    }
                    hasFinished = true
                }

                yearlyTotals.forEach { variable, value in
                    totals[variable] = (totals[variable] ?? 0) + value
                }
            } catch {
                hasFinished = true
            }
        }

        return totals
    }

    private func fetchYear(_ year: Int, device: Device) async throws -> ([ReportVariable: Double], Int?) {
        let reportVariables = [ReportVariable.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads]
        let reports = try await networking.fetchReport(deviceID: device.deviceID,
                                                       variables: reportVariables,
                                                       queryDate: QueryDate(year: year, month: nil, day: nil),
                                                       reportType: .year)

        var totals = [ReportVariable: Double]()
        reports.forEach { reportResponse in
            guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

            totals[reportVariable] = reportResponse.data.map { abs($0.value) }.reduce(0.0, +)
        }

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        var emptyMonth: Int?
        for month in (1 ... 12).reversed() {
            var monthlyTotal: Double = 0

            reportVariables.forEach { variable in
                if let report = reports.first(where: { $0.variable == variable.networkTitle }),
                   let monthlyAmount = report.data.first(where: { $0.index == month })?.value {
                    monthlyTotal = monthlyTotal + monthlyAmount
                }
            }

            if monthlyTotal == 0 && (month < currentMonth || year < currentYear) {
                emptyMonth = month + 1
                break
            }
        }

        return (totals, emptyMonth)
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

        return approximationsCalculator.calculateApproximations(grid: grid,
                                                                feedIn: feedIn,
                                                                loads: loads,
                                                                batteryCharge: batteryCharge,
                                                                batteryDischarge: batteryDischarge,
                                                                earnings: response)
    }
}
