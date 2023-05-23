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
                await load()
            }
        }
    }

    var stride: Int = 3
    private var rawData: [StatsGraphValue] = []
    @Published var data: [StatsGraphValue] = []
    @Published var unit: Calendar.Component = .hour
    @Published var graphVariables: [StatsGraphVariable] = []
    private var totals: [ReportVariable: Double] = [:]
    private var max: StatsGraphValue?

    init(networking: Networking, configManager: ConfigManaging) {
        self.networking = networking
        self.configManager = configManager

        graphVariables = [.generation, ReportVariable.feedIn, .gridConsumption, .chargeEnergyToTal, .dischargeEnergyToTal].map {
            StatsGraphVariable($0)
        }

        haptic.prepare()
    }

    func load() async {
        guard let currentDevice = configManager.currentDevice.value else { return }

        let reportVariables: [ReportVariable] = [.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption]
        let queryDate = makeQueryDate()
        let reportType = makeReportType()

        do {
            let reports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate, reportType: reportType)

            totals = [:]

            let updatedData = reports.flatMap { reportResponse -> [StatsGraphValue] in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return [] }

                totals[reportVariable] = reportResponse.data.map { abs($0.value) }.reduce(0.0, +)

                return reportResponse.data.map { dataPoint in
                    var graphPointDate = Date.yesterday()

                    switch displayMode {
                    case .day(let date):
                        graphPointDate = Calendar.current.date(from: DateComponents(year: Calendar.current.component(.year, from: date),
                                                                                    month: Calendar.current.component(.month, from: date),
                                                                                    day: Calendar.current.component(.day, from: date),
                                                                                    hour: dataPoint.index - 1, minute: 0))!
                    case .month(let month, let year):
                        graphPointDate = Calendar.current.date(from: DateComponents(year: year, month: month, day: dataPoint.index, hour: 0))!
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
                refresh()
            }
        } catch {
            await MainActor.run {
                self.state = .error(error, "Could not load, check your connection")
            }
        }
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

        return result
    }

    func unitFormatted(_ date: Date) -> String {
        switch displayMode {
        case .day:
            return DateFormatter.dayHour.string(from: date)
        case .month:
            return DateFormatter.dayMonth.string(from: date)
        case .year:
            return DateFormatter.monthYear.string(from: date)
        }
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
