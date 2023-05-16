//
//  StatsTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 15/05/2023.
//

import Energy_Stats_Core
import Foundation

class StatsTabViewModel: ObservableObject {
    private let configManager: ConfigManaging
    private let networking: Networking

    @Published var state = LoadState.inactive
    @Published var displayMode: StatsDisplayMode = .day(.yesterday()) {
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

    init(networking: Networking, configManager: ConfigManaging) {
        self.networking = networking
        self.configManager = configManager

        graphVariables = [ReportVariable.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption].map {
            StatsGraphVariable($0, isSelected: true)
        }
    }

    func data(at date: Date) -> ValuesAtTime {
        ValuesAtTime(values: [])
    }

    func load() async {
        guard let currentDevice = configManager.currentDevice.value else { return }

        let reportVariables: [ReportVariable] = [.feedIn, .generation, .chargeEnergyToTal, .dischargeEnergyToTal, .gridConsumption]
        let queryDate = makeQueryDate()
        let reportType = makeReportType()

        do {
            let reports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate, reportType: reportType)

            let updatedUnit: Calendar.Component
            switch displayMode {
            case .day:
                updatedUnit = .hour
            case .month:
                updatedUnit = .day
            case .year:
                updatedUnit = .month
            }

            let updatedData = reports.flatMap { reportResponse -> [StatsGraphValue] in
                guard let reportVariable = ReportVariable(rawValue: reportResponse.variable) else { return [] }

                return reportResponse.data.map { dataPoint in
                    var graphPointDate = Date.yesterday()

                    switch displayMode {
                    case .day(let date):
                        graphPointDate = date
                        graphPointDate = Calendar.current.date(from: DateComponents(hour: dataPoint.index - 1, minute: 0))!
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
                self.unit = updatedUnit
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

//        max = refreshedData.max(by: { lhs, rhs in
//            lhs.value < rhs.value
//        })
        data = refreshedData

//        let scaleMin = ((refreshedData.min(by: { lhs, rhs in lhs.value < rhs.value })?.value) ?? 0) - 0.5
//        let scaleMax = ((max?.value) ?? 0) + 0.5
//        yScale = scaleMin ... scaleMax
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
}

private extension StatsTabViewModel {
    func makeQueryDate() -> QueryDate {
        switch displayMode {
        case .day(let date):
            return QueryDate(year: Calendar.current.component(.year, from: date),
                             month: Calendar.current.component(.month, from: date),
                             day: Calendar.current.component(.day, from: date))
        case .month(let month, let year):
            return QueryDate(year: year, month: month, day: nil)
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
