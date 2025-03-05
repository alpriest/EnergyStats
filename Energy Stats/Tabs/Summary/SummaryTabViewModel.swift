//
//  SummaryTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 07/11/2023.
//

import Combine
import Energy_Stats_Core
import Foundation

class SummaryTabViewModel: ObservableObject {
    private let networking: Networking
    private var configManager: ConfigManaging
    @Published var isLoading = false
    @Published var approximationsViewModel: ApproximationsViewModel? = nil
    @Published var oldestDataDate: String = ""
    @Published var latestDataDate: String = ""
    @Published var currencySymbol: String = ""
    private let approximationsCalculator: ApproximationsCalculator
    private var themeChangeCancellable: AnyCancellable?
    @Published var summaryDateRange: SummaryDateRange

    init(configManager: ConfigManaging, networking: Networking) {
        self.networking = networking
        self.configManager = configManager
        summaryDateRange = configManager.summaryDateRange
        approximationsCalculator = ApproximationsCalculator(configManager: configManager, networking: networking)
        themeChangeCancellable = self.configManager.appSettingsPublisher.sink { theme in
            Task { @MainActor in
                self.currencySymbol = theme.currencySymbol
            }
        }
    }

    func load() {
        guard approximationsViewModel == nil else { return }
        guard let currentDevice = configManager.currentDevice.value else { return }

        Task { @MainActor in
            isLoading = true
            let totals = try await fetchAllYears(device: currentDevice)

            self.approximationsViewModel = makeApproximationsViewModel(totals: totals)

            isLoading = false
        }
    }

    func setDateRange(dateRange: SummaryDateRange) {
        configManager.summaryDateRange = dateRange
        summaryDateRange = dateRange
        approximationsViewModel = nil
        load()
    }

    private var fromYear: Int {
        switch configManager.summaryDateRange {
        case .automatic:
            2020
        case .manual(let from, _):
            from.year
        }
    }

    private var toYear: Int {
        switch configManager.summaryDateRange {
        case .automatic:
            Calendar.current.component(.year, from: Date())
        case .manual(_, let to):
            to.year
        }
    }

    private var toDateDescription: String {
        switch configManager.summaryDateRange {
        case .automatic:
            "present"
        case .manual(_, let to):
            "\(to.monthYear()) (manually selected)"
        }
    }

    private func fetchAllYears(device: Device) async throws -> [ReportVariable: Double] {
        var totals = [ReportVariable: Double]()
        var hasFinished = false
        await MainActor.run {
            latestDataDate = toDateDescription
        }

        for year in (fromYear ... toYear).reversed() {
            if hasFinished {
                break
            }

            do {
                let (yearlyTotals, emptyMonth) = try await fetchYear(year, device: device)

                if let emptyMonth {
                    await MainActor.run {
                        switch configManager.summaryDateRange {
                        case .automatic:
                            oldestDataDate = Date.from(year: year, month: emptyMonth).monthYear()
                        case .manual(let from, _):
                            oldestDataDate = "\(from.monthYear())"
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
        let reportVariables = [ReportVariable.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads, .pvEnergyTotal]
        let rawReports = try await networking.fetchReport(deviceSN: device.deviceSN,
                                                          variables: reportVariables,
                                                          queryDate: QueryDate(year: year, month: nil, day: nil),
                                                          reportType: .year)
        let reports = filterUnrequestedMonths(year: year, reports: rawReports)

        var totals = [ReportVariable: Double]()
        reports.forEach { reportResponse in
            guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

            totals[reportVariable] = reportResponse.values.map { abs($0.value) }.reduce(0.0, +)
        }

        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        var emptyMonth: Int?
        for month in (1 ... 12).reversed() {
            var monthlyTotal: Double = 0

            reportVariables.forEach { variable in
                if let report = reports.first(where: { $0.variable == variable.networkTitle }),
                   let monthlyAmount = report.values.first(where: { $0.index == month })?.value
                {
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

    private func filterUnrequestedMonths(year: Int, reports: [OpenReportResponse]) -> [OpenReportResponse] {
        switch configManager.summaryDateRange {
        case .automatic:
            reports
        case .manual(from: let from, to: let to):
            reports.map { report in
                OpenReportResponse(variable: report.variable,
                                   unit: report.unit,
                                   values: report.values.compactMap { reportData in
                                       if year == from.year, reportData.index < from.month {
                                           return OpenReportResponse.ReportData(index: reportData.index, value: 0)
                                       }

                                       if year == to.year, reportData.index > to.month {
                                           return OpenReportResponse.ReportData(index: reportData.index, value: 0)
                                       }

                                       return OpenReportResponse.ReportData(index: reportData.index, value: reportData.value)
                                   })
            }
        }
    }

    private func makeApproximationsViewModel(
        totals: [ReportVariable: Double]
    ) -> ApproximationsViewModel? {
        guard let grid = totals[ReportVariable.gridConsumption],
              let feedIn = totals[ReportVariable.feedIn],
              let loads = totals[ReportVariable.loads],
              let batteryCharge = totals[ReportVariable.chargeEnergyToTal],
              let batteryDischarge = totals[ReportVariable.dischargeEnergyToTal],
              let solar = totals[ReportVariable.pvEnergyTotal]
        else {
            return nil
        }

        return approximationsCalculator.calculateApproximations(grid: grid,
                                                                feedIn: feedIn,
                                                                loads: loads,
                                                                batteryCharge: batteryCharge,
                                                                batteryDischarge: batteryDischarge,
                                                                solar: solar)
    }
}
