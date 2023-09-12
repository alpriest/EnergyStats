//
//  StatsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

class StatsTabViewModel: ObservableObject {
    private let haptic = UIImpactFeedbackGenerator()
    private let configManager: ConfigManaging
    private let networking: Networking

    @Published var state = LoadState.inactive
    @Published var displayMode: StatsDisplayMode = .day(Date()) {
        didSet {
            Task { @MainActor in
                selectedDate = nil
                valuesAtTime = nil
                await load()
            }
        }
    }

    @Published var valuesAtTime: ValuesAtTime<StatsGraphValue>?
    @Published var selectedDate: Date?

    var stride: Int = 3
    private var rawData: [StatsGraphValue] = []
    @Published var data: [StatsGraphValue] = []
    @Published var unit: Calendar.Component = .hour
    @Published var graphVariables: [StatsGraphVariable] = []
    @Published var netSelfSufficiencyEstimate: String? = nil
    @Published var absoluteSelfSufficiencyEstimate: String? = nil
    @Published var homeUsage: Double? = nil
    @Published var totalSolarGenerated: Double? = nil
    private var totals: [ReportVariable: Double] = [:]
    private var max: StatsGraphValue?
    var exportFile: CSVTextFile?

    init(networking: Networking, configManager: ConfigManaging) {
        self.networking = networking
        self.configManager = configManager

        graphVariables = [.generation, ReportVariable.feedIn, .gridConsumption, .chargeEnergyToTal, .dischargeEnergyToTal, .loads].map {
            StatsGraphVariable($0)
        }

        haptic.prepare()
    }

    func load() async {
        guard let currentDevice = configManager.currentDevice.value else { return }

        let reportVariables: [ReportVariable] = [.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption, .loads]
        let queryDate = makeQueryDate()
        let reportType = makeReportType()

        do {
            let reports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate, reportType: reportType)
            totals = try await generateTotals(currentDevice: currentDevice, reportType: reportType, queryDate: queryDate, reports: reports, reportVariables: reportVariables)

            let updatedData = reports.flatMap { reportResponse -> [StatsGraphValue] in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return [] }

                return reportResponse.data.map { dataPoint in
                    var graphPointDate = Date.yesterday()

                    switch displayMode {
                    case .day(let date):
                        graphPointDate = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date),
                                                                                    month: Calendar.current.component(.month, from: date),
                                                                                    day: Calendar.current.component(.day, from: date),
                                                                                    hour: dataPoint.index - 1, minute: 0))!
                    case .month(let month, let year):
                        graphPointDate = Calendar.current.date(from: DateComponents(year: year, month: month + 1, day: dataPoint.index, hour: 0))!
                    case .year(let year):
                        graphPointDate = Calendar.current.date(from: DateComponents(year: year, month: dataPoint.index, day: 1, hour: 0))!
                    }

                    return StatsGraphValue(
                        date: graphPointDate, value: dataPoint.value, type: reportVariable
                    )
                }
            }

            await MainActor.run {
                self.unit = displayMode.unit()
                self.rawData = updatedData
                calculateSelfSufficiencyEstimate()
                refresh()
                prepareExport()
            }
        } catch {
            await MainActor.run {
                self.state = .error(error, "Could not load, check your connection")
            }
        }
    }

    func calculateSelfSufficiencyEstimate() {
        guard let grid = totals[ReportVariable.gridConsumption],
              let feedIn = totals[ReportVariable.feedIn],
              let loads = totals[ReportVariable.loads],
              let batteryCharge = totals[ReportVariable.chargeEnergyToTal],
              let batteryDischarge = totals[ReportVariable.dischargeEnergyToTal]
        else { return }

        calculateSelfSufficiencyEstimate(grid: grid,
                                         feedIn: feedIn,
                                         loads: loads,
                                         batteryCharge: batteryCharge,
                                         batteryDischarge: batteryDischarge)
    }

    func calculateSelfSufficiencyEstimate(
        grid: Double,
        feedIn: Double,
        loads: Double,
        batteryCharge: Double,
        batteryDischarge: Double
    ) {
        homeUsage = loads
        totalSolarGenerated = Swift.max(0, batteryCharge - batteryDischarge - grid + loads + feedIn)

        let netResult = NetSelfSufficiencyCalculator.calculate(
            grid: grid,
            feedIn: feedIn,
            loads: loads,
            batteryCharge: batteryCharge,
            batteryDischarge: batteryDischarge
        )
        netSelfSufficiencyEstimate = asPercent(netResult)

        let absoluteResult = AbsoluteSelfSufficiencyCalculator.calculate(
            loads: loads,
            grid: grid
        )
        absoluteSelfSufficiencyEstimate = asPercent(absoluteResult)
    }

    func asPercent(_ value: Double) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .percent
        numberFormatter.maximumFractionDigits = 1

        return numberFormatter.string(from: NSNumber(value: value))
    }

    func generateTotals(
        currentDevice: Device,
        reportType: ReportType,
        queryDate: QueryDate,
        reports: [ReportResponse],
        reportVariables: [ReportVariable]
    ) async throws -> [ReportVariable: Double] {
        var totals = [ReportVariable: Double]()

        if case .day = reportType {
            let monthlyReports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate, reportType: .month)

            monthlyReports.forEach { reportResponse in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

                totals[reportVariable] = reportResponse.data.first { $0.index == queryDate.day }?.value ?? 0.0
            }
        } else {
            reports.forEach { reportResponse in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return }

                totals[reportVariable] = reportResponse.data.map { abs($0.value) }.reduce(0.0, +)
            }
        }

        return totals
    }

    func refresh() {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type.networkTitle }

        let refreshedData = rawData
            .filter { !hiddenVariableTypes.contains($0.type.networkTitle) }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })

        max = refreshedData.max(by: { lhs, rhs in
            lhs.value < rhs.value
        })
        data = refreshedData
    }

    func total(of type: ReportVariable?) -> Double? {
        guard let type = type else { return nil }
        guard totals.keys.contains(type) else { return nil }

        return totals[type]
    }

    func toggle(visibilityOf variable: StatsGraphVariable) {
        graphVariables = graphVariables.map {
            if $0.type == variable.type {
                var modified = $0
                modified.enabled.toggle()
                return modified
            } else {
                return $0
            }
        }
    }

    func data(at date: Date?) -> ValuesAtTime<StatsGraphValue> {
        guard let date else { return ValuesAtTime(values: []) }
        let visibleVariableTypes = graphVariables.filter { $0.enabled }.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && visibleVariableTypes.contains($0.type) })

        if let maxDate = max?.date, date == maxDate {
            haptic.impactOccurred()
        }

        if let grid = result.values.first(where: { $0.type == .gridConsumption })?.value,
           let feedIn = result.values.first(where: { $0.type == .feedIn })?.value,
           let loads = result.values.first(where: { $0.type == .loads })?.value,
           let batteryCharge = result.values.first(where: { $0.type == .chargeEnergyToTal })?.value,
           let batteryDischarge = result.values.first(where: { $0.type == .dischargeEnergyToTal })?.value
        {
            calculateSelfSufficiencyEstimate(
                grid: grid,
                feedIn: feedIn,
                loads: loads,
                batteryCharge: batteryCharge,
                batteryDischarge: batteryDischarge
            )
        }

        return result
    }

    func unitFormatted(_ date: Date) -> String {
        switch displayMode {
        case .day:
            return DateFormatter.dayHour.string(from: date)
        case .month:
            if let month = Calendar.current.date(byAdding: .month, value: 1, to: date) {
                return DateFormatter.dayMonth.string(from: month)
            } else { return "" }
        case .year:
            return DateFormatter.monthYear.string(from: date)
        }
    }

    func prepareExport() {
        let headers = ["Type", "Date", "Value"].lazy.joined(separator: ",")
        let rows = rawData.map {
            [$0.type.networkTitle, $0.date.iso8601(), String(describing: $0.value)].lazy.joined(separator: ",")
        }

        let text = ([headers] + rows).joined(separator: "\n")
        let exportFileName: String

        switch displayMode {
        case .day(let date):
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            if let year = components.year, let month = components.month, let day = components.day {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM"
                exportFileName = "energystats_stats_\(year)_\(month)_\(day).csv"
            } else {
                exportFileName = "energystats_stats_unknown_date.csv"
            }
        case .month(let month, let year):
            exportFileName = "energystats_stats_\(year)_\(month + 1).csv"
        case .year(let year):
            exportFileName = "energystats_stats_\(year).csv"
        }

        exportFile = CSVTextFile(text: text, filename: exportFileName)
    }
}

private extension StatsTabViewModel {
    func makeQueryDate() -> QueryDate {
        switch displayMode {
        case .day(let date):
            return QueryDate(year: Calendar.current.component(.year, from: date),
                             month: Calendar.current.component(.month, from: date),
                             day: Calendar.current.component(.day, from: date))
        case .month(let month, let year):
            return QueryDate(year: year, month: month + 1, day: nil)
        case .year(let year):
            return QueryDate(year: year, month: nil, day: nil)
        }
    }

    func makeReportType() -> ReportType {
        switch displayMode {
        case .day:
            return .day
        case .month:
            return .month
        case .year:
            return .year
        }
    }
}
