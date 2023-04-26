//
//  GraphTabViewModel.swift
//  Energy Stats
//
//  Created by Alistair Priest on 08/09/2022.
//

import Energy_Stats_Core
import Foundation
import SwiftUI

struct ValuesAtTime {
    let values: [GraphValue]
}

enum GraphDisplayMode: Equatable {
    case today(_ hours: Int)
    case historic(_ date: Date)
}

class GraphTabViewModel: ObservableObject {
    private let haptic = UIImpactFeedbackGenerator()
    private let networking: Networking
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
    @Published private(set) var graphVariables: [GraphVariable] = [GraphVariable(.generationPower), GraphVariable(RawVariable.batChargePower), GraphVariable(.batDischargePower), GraphVariable(.feedinPower), GraphVariable(.gridConsumptionPower)]
    @Published private(set) var yScale = -0.5 ... 5.0
    private var queryDate = QueryDate.current()
    private var hours: Int = 24

    @Published var displayMode = GraphDisplayMode.today(24) {
        didSet {
            switch displayMode {
            case .today(let hours):
                let previousHours = self.hours
                switch hours {
                case 6:
                    stride = 1
                case 12:
                    stride = 2
                default:
                    stride = 3
                }

                if queryDate != QueryDate(from: dateProvider()) {
                    queryDate = QueryDate(from: dateProvider())
                    Task { @MainActor in
                        await load()
                    }
                }
                if hours != previousHours {
                    self.hours = hours
                    refresh()
                }
            case .historic(let date):
                if queryDate != QueryDate(from: date) {
                    queryDate = QueryDate(from: date)
                    stride = 24
                    Task { @MainActor in
                        await load()
                    }
                }
            }
        }
    }

    private let configManager: ConfigManaging

    init(_ networking: Networking, configManager: ConfigManaging, _ dateProvider: @escaping () -> Date = { Date() }) {
        self.networking = networking
        self.configManager = configManager
        self.dateProvider = dateProvider
        haptic.prepare()
    }

    func load() async {
        guard let currentDevice = configManager.currentDevice else { return }

        Task { @MainActor in
            state = .active(String(localized: "Loading"))
        }

        do {
            let rawVariables = graphVariables.compactMap { $0.type }
            let reportVariables = rawVariables.compactMap { $0.reportVariable }

            let raw = try await networking.fetchRaw(deviceID: currentDevice.deviceID, variables: rawVariables, queryDate: queryDate)
            let rawData: [GraphValue] = raw.flatMap { response -> [GraphValue] in
                guard let rawVariable = RawVariable(rawValue: response.variable) else { return [] }

                return response.data.compactMap {
                    GraphValue(date: $0.time, queryDate: queryDate, value: $0.value, variable: rawVariable)
                }
            }

            let reports = try await networking.fetchReport(deviceID: currentDevice.deviceID, variables: reportVariables, queryDate: queryDate)
            rawVariables.forEach { rawVariable in
                guard let reportVariable = rawVariable.reportVariable else { return }
                guard let response = reports.first(where: { $0.variable == reportVariable.networkTitle }) else { return }

                totals[reportVariable] = 0
                totals[reportVariable] = response.data.map { abs($0.value) }.reduce(0.0, +)
            }

            await MainActor.run {
                self.rawData = rawData
                self.refresh()
                self.state = .inactive
            }
        } catch let error {
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
                if case .today(let hours) = displayMode {
                    let oldest = dateProvider().addingTimeInterval(0 - (3600 * Double(hours)))
                    return value.date > oldest
                } else {
                    return true
                }
            }
            .sorted(by: { lhs, rhs in
                lhs.date < rhs.date
            })

        max = refreshedData.max(by: { lhs, rhs in
            lhs.value < rhs.value
        })
        data = refreshedData

        let scaleMin = ((refreshedData.min(by: { lhs, rhs in lhs.value < rhs.value })?.value) ?? 0) - 0.5
        let scaleMax = ((max?.value) ?? 0) + 0.5
        yScale = scaleMin ... scaleMax
    }

    var max: GraphValue?

    func total(of type: ReportVariable?) -> Double? {
        guard let type = type else { return nil }
        guard totals.keys.contains(type) else { return nil }

        return totals[type]
    }

    func data(at date: Date) -> ValuesAtTime {
        let visibleVariableTypes = graphVariables.filter { $0.enabled }.map { $0.type }
        let result = ValuesAtTime(values: rawData.filter { $0.date == date && visibleVariableTypes.contains($0.variable) })

        if let maxDate = max?.date, date == maxDate {
            haptic.impactOccurred()
        }

        return result
    }

    func toggle(visibilityOf variable: GraphVariable) {
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
