//
//  GraphTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Combine
import Energy_Stats_Core
import Foundation
import SwiftUI

struct ValuesAtTime<T> {
    let values: [T]
}

struct GraphDisplayMode {
    let date: Date
    let hours: Int
}

class ParametersGraphTabViewModel: ObservableObject {
    private let haptic = UIImpactFeedbackGenerator()
    private let networking: Networking
    private let configManager: ConfigManaging
    private var rawData: [GraphValue] = [] {
        didSet {
            data = rawData
        }
    }

    private var totals: [ReportVariable: Double] = [:]
    private let dateProvider: () -> Date
    @Published var state = LoadState.inactive

    @Published private(set) var stride = 3
    @Published private(set) var data: [GraphValue] = []
    @Published var graphVariables: [ParameterGraphVariable] = []
    private var queryDate = QueryDate.current()
    private var hours: Int = 24
    private var max: GraphValue?

    @Published var displayMode = GraphDisplayMode(date: .now, hours: 24) {
        didSet {
            let previousHours = hours

            switch hours {
            case 6:
                stride = 1
            case 12:
                stride = 2
            default:
                stride = 3
            }

            let updatedDate = QueryDate(from: displayMode.date)
            if queryDate != updatedDate {
                queryDate = updatedDate
                Task { @MainActor in
                    await load()
                }
            }
            if displayMode.hours != previousHours {
                hours = displayMode.hours
                refresh()
            }
        }
    }

    static let DefaultGraphVariables = ["generationPower",
                                        "batChargePower",
                                        "batDischargePower",
                                        "feedinPower",
                                        "gridConsumptionPower"]
    private var cancellable: AnyCancellable?

    init(networking: Networking, configManager: ConfigManaging, _ dateProvider: @escaping () -> Date = { Date() }) {
        self.networking = networking
        self.configManager = configManager
        self.dateProvider = dateProvider
        haptic.prepare()

        cancellable = configManager.currentDevice
            .map { device in
                device?.variables.compactMap { variable -> ParameterGraphVariable? in
                    guard let variable = configManager.variables.named(variable.variable) else { return nil }

                    return ParameterGraphVariable(variable, isSelected: Self.DefaultGraphVariables.contains(variable.variable), enabled: Self.DefaultGraphVariables.contains(variable.variable))
                } ?? []
            }
            .receive(on: RunLoop.main)
            .assign(to: \.graphVariables, on: self)
    }

    func load() async {
        guard let currentDevice = configManager.currentDevice.value else { return }

        Task { @MainActor in
            state = .active(String(localized: "Loading"))
        }

        do {
            let rawGraphVariables = graphVariables.filter { $0.isSelected }.compactMap { $0.type }
            let raw = try await networking.fetchRaw(deviceID: currentDevice.deviceID, variables: rawGraphVariables, queryDate: queryDate)
            let rawData: [GraphValue] = raw.flatMap { response -> [GraphValue] in
                guard let rawVariable = configManager.variables.first(where: { $0.variable == response.variable }) else { return [] }

                return response.data.compactMap {
                    GraphValue(date: $0.time, queryDate: queryDate, value: $0.value, variable: rawVariable)
                }
            }

            let reportVariables = rawGraphVariables.compactMap { $0.reportVariable }
            let reports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate, reportType: .day)
            rawGraphVariables.forEach { rawVariable in
                guard let reportVariable = rawVariable.reportVariable else { return }
                guard let response = reports.first(where: { $0.variable.lowercased() == reportVariable.networkTitle.lowercased() }) else { return }

                totals[reportVariable] = 0
                totals[reportVariable] = response.data.map { abs($0.value) }.reduce(0.0, +)
            }

            await MainActor.run {
                self.rawData = rawData
                self.refresh()
                self.state = .inactive
            }
        } catch {
            await MainActor.run {
                self.state = .error(error, "Could not load, check your connection")
            }
        }
    }

    func refresh() {
        let hiddenVariableTypes = graphVariables.filter { $0.enabled == false }.map { $0.type }

        let refreshedData = rawData
            .filter { !hiddenVariableTypes.contains($0.variable) }
            .filter { value in
                let hours = displayMode.hours
                let oldest = displayMode.date.addingTimeInterval(0 - (3600 * Double(hours)))
                return value.date > oldest
            }
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

    func data(at date: Date) -> ValuesAtTime<GraphValue> {
        let visibleVariableTypes = graphVariables.filter { $0.enabled }.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && visibleVariableTypes.contains($0.variable) })

        if let maxDate = max?.date, date == maxDate {
            haptic.impactOccurred()
        }

        return result
    }

    func toggle(visibilityOf variable: ParameterGraphVariable) {
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

    func set(graphVariables: [ParameterGraphVariable]) {
        self.graphVariables = graphVariables
        Task { await load() }
    }

    var axisType: AxisUnit = .consistent("kW")
}

enum AxisUnit {
    case mixed
    case consistent(String)
}
